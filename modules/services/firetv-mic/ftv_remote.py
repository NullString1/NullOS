#!/usr/bin/env python3
"""
ftv_remote.py -- Fire TV BLE remote microphone capture + decode tool.

Reverse-engineered from the FireOS (sheldonp / AFTSSS, Fire OS 7.6.6.9) vendor
partition. Evidence for every constant used here is in BLE_REMOTE_PROTOCOL.md.

Protocol summary (image-proven):
  * The remote is a BLE HID device (vendor 0x0171, product 0x0411..0x0431).
  * HID report 0xF0 and 0xF2 are consumed by Amazon's out-of-tree kernel module
    `hid_ftv_bleremote.ko` (vendor/lib/modules/hid_ftv_bleremote.ko).
  *   report 0xF2  payload 0x01  -> microphone ON   (module .data: "f2 01")
  *   report 0xF2  payload 0x00  -> microphone OFF  (module .data: "f2 00")
  *   report 0xF0  payload      -> raw Opus byte stream (report id stripped)
  *   report 0xEF  payload[0]   -> vendor key page 0xA1..0xA6
  *   report 0x02  usage 0x0221 -> voice key (host sends 0xF2 01 on press)
  * Opus parameters are hard-coded in vendor/lib/hw/audio.btle.default.so:
  *   OpusDecoderInit(channels=1, sampling_rate=0x3E80=16000)
  *   fixed 80-byte (0x50) packets, decoded to 640 bytes PCM (320 samples=20 ms)
  *   no length prefix, no timestamp: the stream is a plain concatenation.

Subcommands
  list                  enumerate hidraw nodes with vendor/product/name/uniq
  desc [dev]            dump + parse the HID report descriptor
  capture [dev]         enable mic, capture reports, write .ftvraw + sidecar json
  decode <file>         decode a .ftvraw capture to WAV
  selftest              end-to-end synthetic test (self-contained, no hardware)

Examples
  sudo ./ftv_remote.py list
  sudo ./ftv_remote.py desc
  sudo ./ftv_remote.py capture -o voice.ftvraw --auto-mic --wav voice.wav
  ./ftv_remote.py decode voice.ftvraw -o voice.wav
  ./ftv_remote.py selftest
"""

from __future__ import annotations

import argparse
import ctypes
import ctypes.util
import errno
import glob
import json
import os
import random
import struct
import sys
import time
import wave

# --------------------------------------------------------------------------
# Protocol constants (see BLE_REMOTE_PROTOCOL.md for the evidence)
# --------------------------------------------------------------------------

AMAZON_VID = 0x0171
REMOTE_PIDS = {
    0x0431, 0x0430, 0x042F, 0x042A, 0x0428, 0x0427, 0x0426, 0x0425,
    0x0424, 0x0423, 0x0421, 0x0420, 0x041E, 0x041F, 0x041C, 0x0419,
    0x0418, 0x0415, 0x0414, 0x0413, 0x0412, 0x0411,
}

RPT_AUDIO = 0xF0          # Opus byte stream, report id stripped by kernel module
RPT_MIC = 0xF2            # microphone enable/disable output report
RPT_VENDOR_KEY = 0xEF     # vendor key page
RPT_CONSUMER = 0x02       # consumer control page (voice key = usage 0x0221)

MIC_ON = b"\xf2\x01"
MIC_OFF = b"\xf2\x00"

CONSUMER_VOICE_USAGE = 0x0221

# Hard-coded in audio.btle.default.so (OpusDecoderInit(1, 0x3E80))
OPUS_RATE = 16000
OPUS_CHANNELS = 1
OPUS_PACKET = 0x50        # 80 bytes, `movs r6, #0x50` in the HAL read loop
OPUS_FRAME_BYTES = 0x280  # 640 bytes PCM == 320 samples == 20 ms

VENDOR_KEYS = {
    0xA1: (0x2E9, "vendor key 0xA1 -> keycode 745"),
    0xA2: (744, "vendor key 0xA2 -> keycode 744 (APP_1)"),
    0xA3: (0x2EA, "vendor key 0xA3 -> keycode 746"),
    0xA4: (0x2EB, "vendor key 0xA4 -> keycode 747"),
    0xA5: (0x246, "vendor key 0xA5 -> keycode 582"),
    0xA6: (372, "vendor key 0xA6 -> keycode 372 (APP_2)"),
}

RAWFMT_MAGIC = b"FTVRAW1\n"
RAWFMT_REC = struct.Struct("<IBH")   # ts_ms u32, report id u8, payload len u16

# --------------------------------------------------------------------------
# Linux hidraw ioctls
# --------------------------------------------------------------------------

_IOC_READ = 2
_IOC_WRITE = 1


def _IOC(direction: int, typ: str, nr: int, size: int) -> int:
    return (direction << 30) | (size << 16) | (ord(typ) << 8) | nr


HIDIOCGRDESCSIZE = _IOC(_IOC_READ, "H", 0x01, 4)
HIDIOCGRDESC = _IOC(_IOC_READ, "H", 0x02, 4100)
HIDIOCGRAWINFO = _IOC(_IOC_READ, "H", 0x03, 8)


def HIDIOCGRAWNAME(n: int) -> int:
    return _IOC(_IOC_READ, "H", 0x04, n)


def HIDIOCGRAWPHYS(n: int) -> int:
    return _IOC(_IOC_READ, "H", 0x05, n)


def HIDIOCGRAWUNIQ(n: int) -> int:
    return _IOC(_IOC_READ, "H", 0x08, n)


BUSTYPES = {0x01: "PCI", 0x03: "USB", 0x05: "Bluetooth", 0x18: "I2C", 0x19: "SPI"}


def hidraw_ioctl(fd: int, req: int, buf, mutate: bool = False):
    import fcntl
    try:
        res = fcntl.ioctl(fd, req, buf, mutate)
    except OSError:
        return None
    return res


def hidraw_info(path: str) -> dict | None:
    try:
        fd = os.open(path, os.O_RDWR | os.O_NONBLOCK)
    except OSError:
        return None
    try:
        info = {"path": path, "vendor": None, "product": None, "bus": None,
                "name": "", "uniq": "", "phys": "", "desc_size": None}
        raw = bytearray(8)
        if hidraw_ioctl(fd, HIDIOCGRAWINFO, raw, True) is not None:
            bustype, vendor, product = struct.unpack("<Ihh", bytes(raw))
            info["bus"] = BUSTYPES.get(bustype, hex(bustype))
            info["vendor"] = vendor & 0xFFFF
            info["product"] = product & 0xFFFF
        for key, reqf in (("name", HIDIOCGRAWNAME), ("phys", HIDIOCGRAWPHYS),
                          ("uniq", HIDIOCGRAWUNIQ)):
            b = bytearray(256)
            if hidraw_ioctl(fd, reqf(len(b)), b, True) is not None:
                info[key] = bytes(b).split(b"\0", 1)[0].decode("utf-8", "replace")
        ds = bytearray(4)
        if hidraw_ioctl(fd, HIDIOCGRDESCSIZE, ds, True) is not None:
            info["desc_size"] = struct.unpack("<I", bytes(ds))[0]
        return info
    finally:
        os.close(fd)


def hidraw_descriptor(path: str) -> bytes:
    fd = os.open(path, os.O_RDWR | os.O_NONBLOCK)
    try:
        buf = bytearray(4100)
        struct.pack_into("<I", buf, 0, 4096)
        if hidraw_ioctl(fd, HIDIOCGRDESC, buf, True) is None:
            raise OSError(errno.ENOTTY, "HIDIOCGRDESC failed", path)
        size = struct.unpack_from("<I", buf, 0)[0]
        return bytes(buf[4:4 + size])
    finally:
        os.close(fd)


def find_remotes() -> list[dict]:
    out = []
    for path in sorted(glob.glob("/dev/hidraw*")):
        info = hidraw_info(path)
        if info and info["vendor"] == AMAZON_VID:
            info["is_remote"] = info["product"] in REMOTE_PIDS
            out.append(info)
    return out


# --------------------------------------------------------------------------
# HID report descriptor parser (just enough to reason about report ids)
# --------------------------------------------------------------------------

USAGE_PAGES = {0x01: "Generic Desktop", 0x09: "Button", 0x0C: "Consumer",
               0x0B: "Telephony", 0xFF00: "Vendor 0xFF00", 0xFF01: "Vendor 0xFF01",
               0xFFA0: "Vendor 0xFFA0"}


def parse_report_descriptor(desc: bytes) -> dict:
    items = []
    i = 0
    while i < len(desc):
        prefix = desc[i]
        i += 1
        if prefix == 0xFE:                     # long item
            if i + 2 > len(desc):
                break
            size, tag = desc[i], desc[i + 1]
            data = desc[i + 2:i + 2 + size]
            i += 2 + size
            items.append({"type": "long", "tag": tag, "data": data.hex()})
            continue
        size = {0: 0, 1: 1, 2: 2, 3: 4}[prefix & 0x03]
        typ = (prefix >> 2) & 0x03
        tag = (prefix >> 4) & 0x0F
        data = desc[i:i + size]
        i += size
        val = int.from_bytes(data, "little") if data else 0
        sval = int.from_bytes(data, "little", signed=True) if data else 0
        items.append({"type": typ, "tag": tag, "value": val, "signed": sval,
                      "size": size})

    reports: dict[tuple[str, int], dict] = {}
    globals_ = {"report_id": 0, "usage_page": 0, "report_size": 0, "report_count": 0,
                "logical_min": 0, "logical_max": 0}
    stack, local_usage, local_usages = [], [], []
    usage_page_names = set()
    collections = []

    for it in items:
        if it["type"] == "long":
            continue
        typ, tag, val = it["type"], it["tag"], it["value"]
        if typ == 1:  # Global
            if tag == 0:
                globals_["usage_page"] = val
                usage_page_names.add(val)
            elif tag == 1:
                globals_["logical_min"] = it["signed"]
            elif tag == 2:
                globals_["logical_max"] = it["signed"]
            elif tag == 7:
                globals_["report_size"] = val
            elif tag == 8:
                globals_["report_id"] = val
            elif tag == 9:
                globals_["report_count"] = val
            elif tag == 10:
                stack.append(dict(globals_))
            elif tag == 11:
                if stack:
                    globals_.update(stack.pop())
        elif typ == 2:  # Local
            if tag == 0:
                local_usage = val
                local_usages.append(val)
        elif typ == 0:  # Main
            if tag == 8:  # Input
                key = ("in", globals_["report_id"])
                r = reports.setdefault(key, {"bits": 0, "count": 0, "usages": [],
                                             "usage_pages": set()})
                r["bits"] += globals_["report_size"] * globals_["report_count"]
                r["count"] += globals_["report_count"]
                r["usages"].extend(local_usages)
                r["usage_pages"].add(globals_["usage_page"])
                local_usages = []
            elif tag == 9:  # Output
                key = ("out", globals_["report_id"])
                r = reports.setdefault(key, {"bits": 0, "count": 0, "usages": [],
                                             "usage_pages": set()})
                r["bits"] += globals_["report_size"] * globals_["report_count"]
                r["count"] += globals_["report_count"]
                r["usages"].extend(local_usages)
                r["usage_pages"].add(globals_["usage_page"])
                local_usages = []
            elif tag == 11:  # Feature
                key = ("feat", globals_["report_id"])
                r = reports.setdefault(key, {"bits": 0, "count": 0, "usages": [],
                                             "usage_pages": set()})
                r["bits"] += globals_["report_size"] * globals_["report_count"]
                r["count"] += globals_["report_count"]
                r["usages"].extend(local_usages)
                r["usage_pages"].add(globals_["usage_page"])
                local_usages = []
            elif tag == 10 and local_usage:
                collections.append((globals_["report_id"], local_usage,
                                    globals_["usage_page"]))
                local_usages = []
    return {"reports": reports, "usage_pages": usage_page_names,
            "collections": collections, "items": items}


def dump_descriptor(desc: bytes) -> None:
    print(f"report descriptor: {len(desc)} bytes")
    print("  " + " ".join(f"{b:02x}" for b in desc[:64]))
    if len(desc) > 64:
        print("  ...")

    parsed = parse_report_descriptor(desc)
    print("\nusage pages referenced:")
    for page in sorted(parsed["usage_pages"]):
        print(f"  0x{page:04x} {USAGE_PAGES.get(page, '')}")

    print("\nreport ids (from descriptor):")
    for (kind, rid) in sorted(parsed["reports"], key=lambda k: (k[1], k[0])):
        r = parsed["reports"][(kind, rid)]
        pages = ",".join(f"0x{p:04x}" for p in sorted(r["usage_pages"]))
        print(f"  {kind:4s} id=0x{rid:02x} count=0x{rid:02x} bits={r['bits']:5d} "
              f"bytes={(r['bits'] + 7) // 8:4d} pages={pages}")
        if r["usages"]:
            head = ", ".join(f"0x{u:04x}" for u in r["usages"][:10])
            print(f"        usages: {head}{' ...' if len(r['usages']) > 10 else ''}")

    for rid in (RPT_AUDIO, RPT_MIC, RPT_CONSUMER, RPT_VENDOR_KEY):
        hits = [k for k in parsed["reports"] if k[1] == rid]
        if hits:
            for k in hits:
                r = parsed["reports"][k]
                print(f"\n  -> report 0x{rid:02x} is declared as {k[0]} "
                      f"({(r['bits'] + 7) // 8} bytes)")
        else:
            print(f"\n  -> report 0x{rid:02x} NOT declared in this descriptor")
    print("\n(note: report ids 0xF0/0xF2 are only meaningful to Amazon's "
          "hid_ftv_bleremote.ko; a host sees them as plain vendor reports)")


# --------------------------------------------------------------------------
# libopus binding
# --------------------------------------------------------------------------

OPUS_APPLICATION_VOIP = 2048
OPUS_SET_BITRATE = 4002
OPUS_SET_VBR = 4006
OPUS_SET_COMPLEXITY = 4010


class Opus:
    def __init__(self) -> None:
        self.lib = self._load()
        L = self.lib
        L.opus_decoder_create.restype = ctypes.c_void_p
        L.opus_decoder_create.argtypes = [ctypes.c_int, ctypes.c_int,
                                          ctypes.POINTER(ctypes.c_int)]
        L.opus_decoder_destroy.restype = None
        L.opus_decoder_destroy.argtypes = [ctypes.c_void_p]
        L.opus_decode.restype = ctypes.c_int
        L.opus_decode.argtypes = [ctypes.c_void_p, ctypes.c_char_p, ctypes.c_int,
                                  ctypes.POINTER(ctypes.c_int16), ctypes.c_int,
                                  ctypes.c_int]
        L.opus_encoder_create.restype = ctypes.c_void_p
        L.opus_encoder_create.argtypes = [ctypes.c_int, ctypes.c_int, ctypes.c_int,
                                          ctypes.POINTER(ctypes.c_int)]
        L.opus_encoder_destroy.restype = None
        L.opus_encoder_destroy.argtypes = [ctypes.c_void_p]
        L.opus_encode.restype = ctypes.c_int
        L.opus_encode.argtypes = [ctypes.c_void_p,
                                  ctypes.POINTER(ctypes.c_int16), ctypes.c_int,
                                  ctypes.c_char_p, ctypes.c_int]
        L.opus_encoder_ctl.restype = ctypes.c_int
        for name in ("opus_packet_get_nb_frames", "opus_packet_get_samples_per_frame",
                     "opus_packet_get_nb_channels"):
            f = getattr(L, name)
            f.restype = ctypes.c_int
        L.opus_packet_get_nb_frames.argtypes = [ctypes.c_char_p, ctypes.c_int]
        L.opus_packet_get_samples_per_frame.argtypes = [ctypes.c_char_p, ctypes.c_int32]
        L.opus_packet_get_nb_channels.argtypes = [ctypes.c_char_p]
        L.opus_strerror.restype = ctypes.c_char_p
        L.opus_strerror.argtypes = [ctypes.c_int]

    @staticmethod
    def _usable(path: str) -> bool:
        """Reject foreign-architecture copies (the nix store can hold a 32-bit ARM
        libopus pulled in by the Android vendor image)."""
        try:
            with open(path, "rb") as fh:
                hdr = fh.read(20)
        except OSError:
            return False
        if hdr[:4] != b"\x7fELF" or hdr[4] != 2:      # ELFCLASS64
            return False
        machine = int.from_bytes(hdr[18:20], "little")
        return machine == 62                          # EM_X86_64
        # (aarch64 hosts: adjust to 183; the CDLL load will succeed anyway if
        #  FTV_LIBOPUS is set explicitly)

    @staticmethod
    def _load():
        cands = []
        env = os.environ.get("FTV_LIBOPUS")
        if env:
            cands.append(env)
        found = ctypes.util.find_library("opus")
        if found:
            cands.append(found)
        for c in cands:
            try:
                return ctypes.CDLL(c)
            except OSError:
                continue
        for c in sorted(glob.glob("/nix/store/*libopus*/lib/libopus.so.0*")):
            if not Opus._usable(c):
                continue
            try:
                return ctypes.CDLL(c)
            except OSError:
                continue
        for c in sorted(glob.glob("/usr/lib*/**/libopus.so.0*", recursive=True)):
            if not Opus._usable(c):
                continue
            try:
                return ctypes.CDLL(c)
            except OSError:
                continue
        raise SystemExit("no usable 64-bit libopus found; run inside "
                         "`nix shell nixpkgs#libopus` "
                         "or set FTV_LIBOPUS=/path/to/libopus.so.0")

    def error(self, code: int) -> str:
        return self.lib.opus_strerror(code).decode()

    def describe_packet(self, pkt: bytes) -> dict:
        L = self.lib
        d = {"len": len(pkt)}
        if not pkt:
            return d
        d["toc"] = pkt[0]
        d["config"] = pkt[0] >> 3
        d["stereo"] = bool(pkt[0] & 0x4)
        d["code"] = pkt[0] & 0x3
        nf = L.opus_packet_get_nb_frames(pkt, len(pkt))
        if nf > 0:
            spf = L.opus_packet_get_samples_per_frame(pkt, ctypes.c_int32(OPUS_RATE))
            d["frames"] = nf
            d["samples_per_frame"] = spf
            d["samples_total"] = nf * spf
            d["ms"] = round(1000.0 * nf * spf / OPUS_RATE, 3)
            d["kbps"] = round(len(pkt) * 8 / (nf * spf / OPUS_RATE) / 1000, 2)
        return d

    def new_decoder(self, rate: int = OPUS_RATE,
                    channels: int = OPUS_CHANNELS) -> "OpusDecoder":
        return OpusDecoder(self, rate, channels)


class OpusDecoder:
    """One persistent decoder for a whole stream.

    This matters: a fresh Opus decoder per packet discards the SILK/CELT
    inter-frame state and the output becomes garbage even though the packet
    framing is correct.
    """

    def __init__(self, opus: "Opus", rate: int, channels: int) -> None:
        self.opus = opus
        self.rate = rate
        self.channels = channels
        err = ctypes.c_int(0)
        self.handle = opus.lib.opus_decoder_create(rate, channels, ctypes.byref(err))
        if err.value != 0 or not self.handle:
            raise RuntimeError(f"opus_decoder_create: {opus.error(err.value)}")
        self.capacity = 5760
        self._out = (ctypes.c_int16 * (self.capacity * channels))()

    def decode(self, pkt: bytes) -> bytes:
        n = self.opus.lib.opus_decode(self.handle, pkt, len(pkt), self._out,
                                      self.capacity, 0)
        if n < 0:
            raise RuntimeError(f"opus_decode: {self.opus.error(n)}")
        return bytes(memoryview(self._out).cast("B")[: n * self.channels * 2])

    def close(self) -> None:
        if self.handle:
            self.opus.lib.opus_decoder_destroy(self.handle)
            self.handle = None

    def __enter__(self):
        return self

    def __exit__(self, *exc):
        self.close()


# --------------------------------------------------------------------------
# .ftvraw container
# --------------------------------------------------------------------------

def write_raw_header(fh) -> None:
    fh.write(RAWFMT_MAGIC)


def read_records(path: str):
    with open(path, "rb") as fh:
        magic = fh.read(len(RAWFMT_MAGIC))
        if magic != RAWFMT_MAGIC:
            raise SystemExit(f"{path}: not a .ftvraw file (bad magic)")
        while True:
            hdr = fh.read(RAWFMT_REC.size)
            if len(hdr) < RAWFMT_REC.size:
                return
            ts_ms, rid, plen = RAWFMT_REC.unpack(hdr)
            payload = fh.read(plen)
            if len(payload) < plen:
                return
            yield ts_ms, rid, payload


# --------------------------------------------------------------------------
# capture
# --------------------------------------------------------------------------

def pick_device(dev: str | None) -> str:
    if dev:
        return dev
    remotes = [i for i in find_remotes() if i["is_remote"]]
    if not remotes:
        remotes = find_remotes()
    if not remotes:
        raise SystemExit("no Amazon (vendor 0x0171) hidraw device found; "
                         "run `ftv_remote.py list` (needs root for most setups)")
    if len(remotes) > 1:
        print("multiple candidate remotes, using the first:", file=sys.stderr)
    info = remotes[0]
    print(f"using {info['path']} ({info['name']} vid=0x{info['vendor']:04x} "
          f"pid=0x{info['product']:04x} uniq={info['uniq'] or '-'})", file=sys.stderr)
    return info["path"]


def capture(args) -> int:
    dev = pick_device(args.dev)
    fd = os.open(dev, os.O_RDWR)
    print(f"opened {dev}", file=sys.stderr)

    out = open(args.output, "wb")
    write_raw_header(out)
    sidecar = open(args.output + ".jsonl", "w")
    sidecar.write(json.dumps({
        "tool": "ftv_remote.py", "device": dev, "started": time.time(),
        "rate": OPUS_RATE, "channels": OPUS_CHANNELS, "packet": OPUS_PACKET,
    }) + "\n")

    t0 = time.monotonic()
    packets: list[bytes] = []
    cur = bytearray()
    stats = {"reports": 0, "audio_reports": 0, "audio_bytes": 0,
             "packets": 0, "keys": [], "consumer": []}
    # Assembled packets get their own file: the .ftvraw stream must stay a pure
    # sequence of <=RECORD> entries or read_records() cannot parse it back.
    pktfile = open(args.output + ".pkts", "wb")
    wav = None
    if args.wav:
        wav = wave.open(args.wav, "wb")
        wav.setnchannels(OPUS_CHANNELS)
        wav.setsampwidth(2)
        wav.setframerate(OPUS_RATE)

    opus = Opus() if (args.wav or args.decode_live) else None
    decoder = opus.new_decoder() if opus else None
    mic_on = False

    def emit_packet(pkt: bytes) -> None:
        packets.append(pkt)
        pktfile.write(struct.pack("<H", len(pkt)) + pkt)
        if wav is not None:
            wav.writeframes(decoder.decode(pkt))

    def set_mic(on: bool) -> None:
        nonlocal mic_on
        if mic_on == on:
            return
        try:
            os.write(fd, MIC_ON if on else MIC_OFF)
            mic_on = on
            print(f"-> output report 0x{RPT_MIC:02x} "
                  f"{'01 (mic on)' if on else '00 (mic off)'}", file=sys.stderr)
        except OSError as exc:
            print(f"!! 0xF2 write failed: {exc}", file=sys.stderr)

    if args.auto_mic:
        set_mic(True)

    print("capturing (Ctrl-C to stop) ...", file=sys.stderr)
    deadline = t0 + args.duration if args.duration else None
    try:
        while True:
            if deadline and time.monotonic() >= deadline:
                break
            try:
                data = os.read(fd, 4096)
            except OSError as exc:
                if exc.errno in (errno.EAGAIN, errno.EINTR):
                    time.sleep(0.001)
                    continue
                raise
            if not data:
                time.sleep(0.001)
                continue
            rid, payload = data[0], data[1:]
            ts_ms = int((time.monotonic() - t0) * 1000)
            out.write(RAWFMT_REC.pack(ts_ms, rid, len(payload)) + payload)
            stats["reports"] += 1
            sidecar.write(json.dumps({"t": ts_ms, "id": rid,
                                      "n": len(payload),
                                      "hex": payload.hex()}) + "\n")

            if rid == RPT_AUDIO:
                stats["audio_reports"] += 1
                stats["audio_bytes"] += len(payload)
                cur.extend(payload)
                while len(cur) >= args.packet_size:
                    emit_packet(bytes(cur[:args.packet_size]))
                    del cur[:args.packet_size]
                    stats["packets"] += 1
                if args.print_packets and packets:
                    print(f"pkt {stats['packets']:5d} len={len(packets[-1])} "
                          f"toc=0x{packets[-1][0]:02x} t={ts_ms}ms",
                          file=sys.stderr)
            elif rid == RPT_VENDOR_KEY and payload:
                key = payload[0]
                info = VENDOR_KEYS.get(key)
                stats["keys"].append({"t": ts_ms, "code": key,
                                      "keycode": info[0] if info else None})
                print(f"vendor key 0x{key:02x} {info[1] if info else '(unknown)'}",
                      file=sys.stderr)
            elif rid == RPT_CONSUMER and len(payload) >= 2:
                usage = payload[0] | (payload[1] << 8)
                if usage:
                    stats["consumer"].append({"t": ts_ms, "usage": usage})
                    if usage == CONSUMER_VOICE_USAGE:
                        print(f"voice key usage 0x{usage:04x} pressed", file=sys.stderr)
                        set_mic(True)
                elif args.auto_mic and stats["consumer"]:
                    print("voice key released", file=sys.stderr)
                    if not args.keep_mic:
                        set_mic(False)
    except KeyboardInterrupt:
        pass
    finally:
        if mic_on:
            set_mic(False)
        out.close()
        pktfile.close()
        sidecar.close()
        if wav is not None:
            wav.close()
        os.close(fd)

    dur = time.monotonic() - t0
    stats["duration_s"] = round(dur, 3)
    stats["audio_kbps"] = round(stats["audio_bytes"] * 8 / dur / 1000, 2) if dur else 0
    stats["packet_rate"] = round(stats["packets"] / dur, 2) if dur else 0
    if packets:
        d = Opus().describe_packet(packets[0])
        stats["first_packet"] = d
    print(json.dumps(stats, indent=2))
    print(f"\nwrote {args.output} ({stats['packets']} packets)")
    if args.wav:
        print(f"wrote {args.wav}")
    return 0


# --------------------------------------------------------------------------
# decode
# --------------------------------------------------------------------------

def _score_offset(opus: "Opus", stream: bytes, off: int, limit: int = 300):
    """Score an alignment.

    Two signals, because Opus carries no framing checksum -- `opus_decode()`
    will happily turn misaligned bytes into noise, so "decoded" alone is not
    enough:

      * how many of the 80-byte slices decode at all (weak), and
      * how concentrated the TOC bytes are (strong). The remote emits one
        config repeatedly, so a correct alignment gives a nearly constant first
        byte while a wrong one spreads configs across the whole table.
    """
    ok = bad = 0
    tocs: dict[int, int] = {}
    dec = opus.new_decoder()
    try:
        starts = range(off, len(stream) - OPUS_PACKET + 1, OPUS_PACKET)
        for n, i in enumerate(starts):
            if n >= limit:
                break
            pkt = stream[i:i + OPUS_PACKET]
            tocs[pkt[0]] = tocs.get(pkt[0], 0) + 1
            try:
                if dec.decode(pkt):
                    ok += 1
                else:
                    bad += 1
            except Exception:
                bad += 1
    finally:
        dec.close()
    dominant = max(tocs.values()) if tocs else 0
    return dominant, ok, bad, len(tocs)


def decode_file(path: str, out_wav: str | None, json_out: bool,
                scan: bool = False, offset: int = 0) -> int:
    opus = Opus()
    packets = []
    for ts_ms, rid, payload in read_records(path):
        if rid == RPT_AUDIO:
            packets.append((ts_ms, payload))
    # Re-assemble the 0xF0 byte stream into fixed 80-byte packets.
    stream = b"".join(p for _, p in packets)
    if not stream:
        raise SystemExit(f"{path}: no 0x{RPT_AUDIO:02x} audio reports in this capture")

    if scan:
        rows = []
        for off in range(OPUS_PACKET):
            rows.append((off,) + _score_offset(opus, stream, off))
        # rank by TOC concentration first, then by decode count
        best = max(rows, key=lambda r: (r[1], r[2]))
        for off, dom, ok, bad, ntoc in rows:
            mark = "  <== chosen" if off == best[0] else ""
            if dom >= best[1] * 0.5:
                print(f"  offset {off:2d}: dominant TOC {dom:3d}, "
                      f"{ok:3d} ok / {bad:3d} bad, {ntoc:2d} distinct TOCs{mark}")
        if best[1] < 5:
            raise SystemExit("no alignment produced a consistent Opus stream; "
                             "the capture may have a mid-stream gap")
        offset = best[0]
        print(f"using byte offset {offset} (dominant TOC over {best[1]} packets)")

    pkts = [stream[i:i + OPUS_PACKET]
            for i in range(offset, len(stream) - OPUS_PACKET + 1, OPUS_PACKET)]
    if not pkts:
        raise SystemExit(f"{path}: no complete {OPUS_PACKET}-byte packets "
                         f"({len(stream)} audio bytes, offset {offset})")
    info = [opus.describe_packet(p) for p in pkts]
    decoder = opus.new_decoder()
    pcm_parts = []
    errors = 0
    try:
        for p in pkts:
            try:
                pcm_parts.append(decoder.decode(p))
            except RuntimeError:
                errors += 1
                pcm_parts.append(b"\0" * (OPUS_FRAME_BYTES))
    finally:
        decoder.close()
    pcm = b"".join(pcm_parts)
    summary = {
        "packets": len(pkts),
        "audio_bytes": len(stream),
        "offset": offset,
        "decode_errors": errors,
        "leftover_bytes": (len(stream) - offset) % OPUS_PACKET,
        "pcm_bytes": len(pcm),
        "seconds": round(len(pcm) / (OPUS_RATE * 2), 3),
        "toc_values": sorted({p[0] for p in pkts}),
        "first": info[0],
        "avg_kbps": round(sum(i.get("kbps", 0) for i in info) / len(info), 2),
        "all_20ms": all(i.get("samples_total") == 320 for i in info),
        "all_mono": all(not i.get("stereo") for i in info),
    }
    if json_out:
        print(json.dumps(summary, indent=2))
    if out_wav:
        with wave.open(out_wav, "wb") as w:
            w.setnchannels(OPUS_CHANNELS)
            w.setsampwidth(2)
            w.setframerate(OPUS_RATE)
            w.writeframes(pcm)
        print(f"wrote {out_wav} ({summary['seconds']} s @ {OPUS_RATE} Hz mono)")
    return 0


# --------------------------------------------------------------------------
# selftest: prove the report framing -> packet assembly -> decode path
# --------------------------------------------------------------------------

def selftest(args) -> int:
    opus = Opus()
    n_samples = OPUS_RATE * 2                      # 2 s of audio
    rng = random.Random(0xA1E)
    tone = []
    # A swept sine (300 Hz -> 3000 Hz) plus a little noise: unlike a fixed tone
    # this has a unique autocorrelation peak, so the decoder delay can be
    # measured unambiguously.
    f0, f1, dur = 300.0, 3000.0, n_samples / OPUS_RATE
    for i in range(n_samples):
        t = i / OPUS_RATE
        phase = 2 * 3.141592653589793 * (f0 * t + (f1 - f0) * t * t / (2 * dur))
        v = 0.35 * __import__("math").sin(phase) + 0.05 * (rng.random() * 2 - 1)
        tone.append(int(max(-32768, min(32767, v * 32767))))
    pcm_in = (ctypes.c_int16 * n_samples)(*tone)

    err = ctypes.c_int(0)
    enc = opus.lib.opus_encoder_create(OPUS_RATE, OPUS_CHANNELS,
                                       OPUS_APPLICATION_VOIP, ctypes.byref(err))
    if err.value != 0:
        raise SystemExit(f"opus_encoder_create: {opus.error(err.value)}")
    opus.lib.opus_encoder_ctl(ctypes.c_void_p(enc), OPUS_SET_BITRATE, 32000)
    opus.lib.opus_encoder_ctl(ctypes.c_void_p(enc), OPUS_SET_VBR, 0)
    opus.lib.opus_encoder_ctl(ctypes.c_void_p(enc), OPUS_SET_COMPLEXITY, 10)

    frame = 320                                    # 20 ms @ 16 kHz
    outbuf = ctypes.create_string_buffer(4000)
    packets = []
    for off in range(0, n_samples - frame + 1, frame):
        ptr = ctypes.cast(ctypes.byref(pcm_in, off * 2),
                          ctypes.POINTER(ctypes.c_int16))
        n = opus.lib.opus_encode(enc, ptr, frame, outbuf, OPUS_PACKET)
        if n < 0:
            raise SystemExit(f"opus_encode: {opus.error(n)}")
        packets.append(outbuf.raw[:n])
    opus.lib.opus_encoder_destroy(enc)

    print(f"encoder: {len(packets)} packets, sizes "
          f"{sorted({len(p) for p in packets})}, toc {sorted({p[0] for p in packets})}")

    # --- build a synthetic .ftvraw stream, exactly like hidraw would deliver it
    path = args.output or "/tmp/opencode/firetv/selftest.ftvraw"
    mtu = args.mtu
    with open(path, "wb") as fh:
        write_raw_header(fh)
        ts = 0
        for pkt in packets:
            for i in range(0, len(pkt), mtu):
                chunk = pkt[i:i + mtu]
                fh.write(RAWFMT_REC.pack(ts, RPT_AUDIO, len(chunk)) + chunk)
                ts += 1
        # a voice-key press and a vendor key, to exercise the parsers
        fh.write(RAWFMT_REC.pack(ts, RPT_CONSUMER, 2) + b"\x21\x02")
        fh.write(RAWFMT_REC.pack(ts + 1, RPT_VENDOR_KEY, 1) + b"\xa2")
    print(f"synthetic capture: {path} (0xF0 split into {mtu}-byte reports)")

    # --- run the real decoder over it
    stream = b"".join(p for _, rid, p in read_records(path) if rid == RPT_AUDIO)
    assert len(stream) == sum(len(p) for p in packets), "report reassembly lost bytes"
    rebuilt = [stream[i:i + OPUS_PACKET] for i in range(0, len(stream), OPUS_PACKET)]
    assert rebuilt == packets, "packetisation mismatch"

    decoder = opus.new_decoder()
    try:
        pcm_out = b"".join(decoder.decode(p) for p in rebuilt)
    finally:
        decoder.close()
    # Opus is lossy and has an algorithmic delay (lookahead + resampling), so
    # align the decoded signal against the source before measuring SNR.
    import math
    dec = memoryview(pcm_out).cast("h")
    n = min(len(dec), n_samples)

    best_lag, best_err = 0, None
    for lag in range(0, 600):
        if n - lag < 8000:
            break
        err = sum((tone[i] - dec[i + lag]) ** 2 for i in range(4000, 12000))
        if best_err is None or err < best_err:
            best_lag, best_err = lag, err
    m = n - best_lag
    sig = sum(tone[i] * tone[i] for i in range(m))
    noise = sum((tone[i] - dec[i + best_lag]) ** 2 for i in range(m))
    snr = 10 * math.log10(sig / noise) if noise else float("inf")
    print(f"decoded {len(pcm_out)} bytes PCM ({len(pcm_out) / 2 / OPUS_RATE:.3f} s)")
    print(f"Opus algorithmic delay: {best_lag} samples "
          f"({1000 * best_lag / OPUS_RATE:.2f} ms)")
    print(f"SNR vs source (delay-compensated): {snr:.1f} dB")

    wav = args.wav or "/tmp/opencode/firetv/selftest.wav"
    with wave.open(wav, "wb") as w:
        w.setnchannels(OPUS_CHANNELS)
        w.setsampwidth(2)
        w.setframerate(OPUS_RATE)
        w.writeframes(pcm_out)
    print(f"wrote {wav}")

    d = opus.describe_packet(rebuilt[0])
    ok = (rebuilt == packets and snr > 15 and d["samples_total"] == 320
          and not d["stereo"] and len(stream) % OPUS_PACKET == 0)
    print(f"first packet: {json.dumps(d)}")
    print("SELFTEST", "PASS" if ok else "FAIL")
    return 0 if ok else 1


# --------------------------------------------------------------------------

def main(argv) -> int:
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    sub = ap.add_subparsers(dest="cmd", required=True)

    sub.add_parser("list", help="enumerate hidraw devices")

    p = sub.add_parser("desc", help="dump the HID report descriptor")
    p.add_argument("dev", nargs="?")

    p = sub.add_parser("capture", help="capture reports to .ftvraw")
    p.add_argument("dev", nargs="?")
    p.add_argument("-o", "--output", default="capture.ftvraw")
    p.add_argument("--wav", help="also decode live into this WAV")
    p.add_argument("--duration", type=float, default=0, help="seconds (0 = until Ctrl-C)")
    p.add_argument("--auto-mic", action="store_true",
                   help="send 0xF2 01 at start and on voice-key press")
    p.add_argument("--keep-mic", action="store_true",
                   help="do not send 0xF2 00 when the voice key is released")
    p.add_argument("--packet-size", type=int, default=OPUS_PACKET)
    p.add_argument("--decode-live", action="store_true")
    p.add_argument("--print-packets", action="store_true")

    p = sub.add_parser("decode", help="decode a .ftvraw capture")
    p.add_argument("file")
    p.add_argument("-o", "--wav")
    p.add_argument("--json", action="store_true")
    p.add_argument("--scan", action="store_true",
                   help="try all 80 byte offsets and use the one that decodes cleanly")
    p.add_argument("--offset", type=int, default=0,
                   help="byte offset of the first packet (default 0)")

    p = sub.add_parser("selftest", help="end-to-end synthetic validation")
    p.add_argument("--output")
    p.add_argument("--wav")
    p.add_argument("--mtu", type=int, default=20,
                   help="split 0xF0 payload into this many bytes per report")

    args = ap.parse_args(argv)

    if args.cmd == "list":
        devs = find_remotes()
        if not devs:
            print("no Amazon (0x0171) hidraw devices found")
            for path in sorted(glob.glob("/dev/hidraw*")):
                print("  (other)", path, hidraw_info(path))
            return 1
        for d in devs:
            tag = "REMOTE" if d["is_remote"] else "amazon?"
            print(f"{d['path']}  {tag}  bus={d['bus']} pid=0x{d['product']:04x} "
                  f"name={d['name']!r} phys={d['phys']!r} uniq={d['uniq']!r} "
                  f"desc={d['desc_size']}B")
        return 0
    if args.cmd == "desc":
        return dump_descriptor(hidraw_descriptor(pick_device(args.dev))) or 0
    if args.cmd == "capture":
        return capture(args)
    if args.cmd == "decode":
        return decode_file(args.file, args.wav, args.json,
                           scan=args.scan, offset=args.offset)
    if args.cmd == "selftest":
        return selftest(args)
    return 2


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
