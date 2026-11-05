#!/usr/bin/env python3
"""ftv_mic_bridge.py - feed the Fire TV BLE remote's microphone into Android.

Why this works
--------------
Waydroid's audio HAL (`audio.primary.waydroid.so`) opens the ALSA device named
"pulse" with `PULSE_RUNTIME_PATH` pointing at the host's PulseAudio socket, so
Android's "Built-In Mic" *is* the host PipeWire default source.

We therefore never touch Android.  A `pw-loopback` node exposes:

    firetv_mic_in   (Audio/Sink)    <- this daemon writes PCM here
    firetv_mic      (Audio/Source)  -> whatever Android records from

`firetv_mic` is pinned as the default source, so Assistant/katniss, voice
search and any other AudioRecord client receive the remote's audio with no
further changes.

The remote side
---------------
  * vendor output report 0xF2 0x01 / 0x00 enables/disables the mic
  * report 0xF0 carries a raw concatenated Opus stream, 80-byte packets,
    16 kHz mono, 20 ms per packet
  * consumer usage 0x0221 is the voice key (press/release)

A single persistent Opus decoder is used for the whole run: a fresh decoder
per packet throws away SILK/CELT state and produces garbage.

Usage
-----
    ./ftv_mic_bridge.py                  # voice key drives the mic
    ./ftv_mic_bridge.py --follow-capture  # also follow Android recording
    ./ftv_mic_bridge.py --always-on       # keep the remote mic open
"""
import argparse
import errno
import json
import os
import select
import shutil
import signal
import subprocess
import sys
import time

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)

import ftv_remote as ftv  # noqa: E402

TOOLS = {
    "pw-cat": ("/run/current-system/sw/bin/pw-cat",),
    "pw-link": ("/run/current-system/sw/bin/pw-link",),
    "pw-cli": ("/run/current-system/sw/bin/pw-cli",),
    "pw-dump": ("/run/current-system/sw/bin/pw-dump",),
    "pw-loopback": ("/run/current-system/sw/bin/pw-loopback",),
    "wpctl": ("/run/current-system/sw/bin/wpctl",),
}


def find_exe(name):
    exe = shutil.which(name)
    if exe:
        return exe
    for cand in TOOLS.get(name, ()):
        if os.path.isabs(cand) and os.access(cand, os.X_OK):
            return cand
        found = shutil.which(cand)
        if found:
            return found
    raise SystemExit(f"{name} not found on PATH")


def log(msg):
    print(msg, file=sys.stderr, flush=True)


class Sink:
    """A long-lived `pw-cat --playback` writing raw PCM into the virtual sink."""

    def __init__(self, target, rate=16000, channels=1, latency=None):
        self.target = target
        self.exe = find_exe("pw-cat")
        self.rate = rate
        self.channels = channels
        self.latency = latency
        self.proc = None
        self.start()

    def linked(self):
        """True if our pw-cat stream is actually feeding the virtual sink.

        `pw-cat --target` is resolved by WirePlumber, not by the PipeWire
        daemon.  If WirePlumber has not registered the loopback node yet
        (a real race at boot: the node exists in the graph a second before
        WirePlumber knows it) the target silently fails to resolve and
        pw-cat attaches to the *default sink* instead -- which is the TV's
        HDMI output, so the decoded microphone audio is played out loud
        and Android records nothing.  Never trust --target; verify.
        """
        try:
            out = subprocess.run([find_exe("pw-link"), "-l"],
                                 capture_output=True, text=True,
                                 timeout=5).stdout
        except Exception:
            return False
        return f"-> {self.target}:playback" in out

    def _wait_linked(self, timeout=3.0):
        deadline = time.monotonic() + timeout
        while time.monotonic() < deadline:
            if not self.alive():
                return False
            if self.linked():
                return True
            time.sleep(0.15)
        return self.linked()

    def start(self):
        # --raw is mandatory for "-": without it pw-cat tries to sniff a
        # container format, fails with "Format not recognised", and exits,
        # which surfaces here as a broken pipe on the first write.
        cmd = [self.exe, "--playback", "--target", self.target,
               "--rate", str(self.rate), "--channels", str(self.channels),
               "--format", "s16", "--raw"]
        if self.latency:
            cmd += ["--latency", self.latency]
        cmd.append("-")
        for attempt in range(1, 6):
            self.proc = subprocess.Popen(cmd, stdin=subprocess.PIPE,
                                         bufsize=0,
                                         stderr=subprocess.DEVNULL)
            if self._wait_linked():
                log(f"sink: pw-cat -> {self.target} ({self.rate} Hz "
                    f"{self.channels}ch s16)")
                return
            log(f"sink: {self.target} not attachable yet "
                f"(attempt {attempt}/5); retrying")
            self.close()
            time.sleep(0.5)
        log(f"sink: !! could not attach to {self.target}; "
            f"microphone audio will NOT reach Android")

    def restart(self):
        self.close()
        self.start()

    def alive(self):
        return self.proc is not None and self.proc.poll() is None

    def write(self, pcm):
        if not pcm:
            return
        for attempt in (0, 1):
            if not self.alive():
                log("sink: writer gone; restarting")
                self.close()
                self.start()
            try:
                self.proc.stdin.write(pcm)
                return
            except (BrokenPipeError, ValueError, OSError) as exc:
                if attempt:
                    log(f"sink: write failed ({exc}); dropping audio")
                    return
                log(f"sink: writer died ({exc}); restarting")
                self.close()
                time.sleep(0.2)
                self.start()

    def close(self):
        if self.proc is None:
            return
        try:
            self.proc.stdin.close()
        except Exception:
            pass
        try:
            self.proc.wait(timeout=2)
        except Exception:
            self.proc.kill()
        self.proc = None


class Loopback:
    """Owns the pw-loopback node that exposes firetv_mic{,_in}."""

    def __init__(self, sink_name, source_name, sink_desc, source_desc):
        self.sink_name = sink_name
        self.source_name = source_name
        self.sink_desc = sink_desc
        self.source_desc = source_desc
        self.proc = None

    def _nodes(self):
        try:
            out = subprocess.run([find_exe("pw-cli"), "ls", "Node"],
                                 capture_output=True, text=True, timeout=5).stdout
        except Exception:
            return ""
        return out

    def _wp_knows(self, names):
        """True once WirePlumber has registered every node in `names`.

        `pw-cli ls Node` only proves the node exists in the PipeWire
        daemon.  WirePlumber keeps its own object database and resolves
        `target.object` against *that*, so a node can be present in the
        graph and still be unusable as a pw-cat target.
        """
        try:
            out = subprocess.run([find_exe("wpctl"), "status"],
                                 capture_output=True, text=True,
                                 timeout=10).stdout
        except Exception:
            return False
        return all(n in out for n in names)

    def _wait_wireplumber(self, timeout=15.0):
        deadline = time.monotonic() + timeout
        while time.monotonic() < deadline:
            if self._wp_knows([self.sink_name, self.source_name]):
                log(f"loopback: WirePlumber knows "
                    f"{self.sink_name}/{self.source_name}")
                return True
            time.sleep(0.2)
        log(f"loopback: WARNING WirePlumber did not register "
            f"{self.sink_name} within {timeout:.0f}s")
        return False

    def ensure(self):
        if f'node.name = "{self.source_name}"' in self._nodes():
            log(f"loopback: {self.source_name} already present")
            self._wait_wireplumber()
            return
        cmd = [find_exe("pw-loopback"),
               "--capture-props",
               f"media.class=Audio/Sink node.name={self.sink_name} "
               f"node.description={self.sink_desc}",
               "--playback-props",
               f"media.class=Audio/Source node.name={self.source_name} "
               f"node.description={self.source_desc} "
               # keep WirePlumber from preferring the analog mic as default
               f"priority.session=30000"]
        self.proc = subprocess.Popen(cmd, stdout=subprocess.DEVNULL,
                                     stderr=subprocess.DEVNULL)
        log(f"loopback: started {self.sink_name} -> {self.source_name}")
        for _ in range(50):
            time.sleep(0.1)
            if f'node.name = "{self.source_name}"' in self._nodes():
                break
        else:
            log("loopback: WARNING node did not appear")
            return
        self._wait_wireplumber()

    def alive(self):
        """True while pw-loopback runs *and* its nodes are still in the graph.

        The process can survive while its nodes are destroyed and rebuilt
        (they come back with new ids and fresh serials), so both checks
        matter: a live pid alone does not mean `firetv_mic_in` is usable.
        """
        if self.proc is None or self.proc.poll() is not None:
            return False
        return (f'node.name = "{self.sink_name}"' in self._nodes()
                and f'node.name = "{self.source_name}"' in self._nodes())

    def stop(self):
        if self.proc and self.proc.poll() is None:
            self.proc.terminate()
            try:
                self.proc.wait(timeout=2)
            except Exception:
                self.proc.kill()


def set_default_source(name):
    """Pin `name` as the PipeWire default source (what Android captures)."""
    try:
        dump = subprocess.run([find_exe("pw-dump")], capture_output=True,
                              text=True, timeout=15).stdout
        for obj in json.loads(dump):
            props = (obj.get("info") or {}).get("props") or {}
            if props.get("node.name") == name and \
                    props.get("media.class") == "Audio/Source":
                subprocess.run([find_exe("wpctl"), "set-default", str(obj["id"])],
                               capture_output=True, timeout=10)
                log(f"default source: {name} (node {obj['id']})")
                return obj["id"]
    except Exception as exc:
        log(f"default source: could not pin {name}: {exc}")
    return None


class CaptureWatch:
    """Detect whether something is recording from our virtual source."""

    def __init__(self, source_name):
        self.source_name = source_name
        self.exe = find_exe("pw-link")

    def active(self):
        try:
            out = subprocess.run([self.exe, "-l"], capture_output=True,
                                 text=True, timeout=3).stdout
        except Exception:
            return False
        # links print as:  <src>:<port>   |-> <dst>:<port>
        for line in out.splitlines():
            if "|->" in line:
                src = line.split("|->")[0].strip()
                if src.startswith(self.source_name + ":"):
                    return True
        return False


def wait_for_pipewire(timeout=30.0):
    """Block until the PipeWire daemon answers (a user service can start first)."""
    deadline = time.monotonic() + timeout
    while time.monotonic() < deadline:
        try:
            rc = subprocess.run([find_exe("pw-cli"), "info", "0"],
                                capture_output=True, timeout=5).returncode
            if rc == 0:
                return True
        except Exception:
            pass
        time.sleep(0.5)
    log("pipewire: not reachable; continuing anyway")
    return False


def open_device(dev_hint):
    """Try once to open the remote. Returns (fd, description) or (None, why).

    Deliberately non-blocking. The caller's main loop has to keep supervising
    the audio graph while the remote sleeps; if this looped here instead, a
    stream that drifted to the wrong sink would stay wrong until somebody
    happened to press a key on the remote.
    """
    try:
        dev = ftv.pick_device(dev_hint)
        fd = os.open(dev, os.O_RDWR)
    except (SystemExit, OSError) as exc:
        return None, str(exc)
    return fd, dev


def main():
    ap = argparse.ArgumentParser(
        description=__doc__,
        formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--device", help="hidraw node (default: first Amazon remote)")
    ap.add_argument("--sink", default="firetv_mic_in",
                    help="virtual sink to write PCM into")
    ap.add_argument("--source", default="firetv_mic",
                    help="virtual source Android records from")
    ap.add_argument("--always-on", action="store_true",
                    help="keep the remote mic enabled permanently")
    ap.add_argument("--keep-mic", action="store_true",
                    help="do not disable the mic on voice-key release")
    ap.add_argument("--follow-capture", action="store_true",
                    help="also enable the mic while Android is recording")
    ap.add_argument("--inject-assist", dest="inject_assist",
                    action="store_true", default=True,
                    help="inject KEYCODE_VOICE_ASSIST into Waydroid on press "
                         "(default: on)")
    ap.add_argument("--no-inject-assist", dest="inject_assist",
                    action="store_false",
                    help="rely on the remote's own HID mapping instead")
    ap.add_argument("--stats", type=float, default=0.0,
                    help="seconds between packet summaries (0 = off)")
    ap.add_argument("--latency", default=None,
                    help="pw-cat latency hint, e.g. 60ms")
    args = ap.parse_args()

    wait_for_pipewire()
    loop = Loopback(args.sink, args.source, "FireTV-Mic-In", "FireTV-Remote-Mic")
    loop.ensure()
    set_default_source(args.source)

    sink = Sink(args.sink, latency=args.latency)
    watch = CaptureWatch(args.source) if args.follow_capture else None

    opus = ftv.Opus()
    decoder = opus.new_decoder(ftv.OPUS_RATE, ftv.OPUS_CHANNELS)

    state = {"mic": False, "key": False, "capture": False,
             "packets": 0, "bytes": 0,
             "t0": time.monotonic(), "last_stats": time.monotonic()}

    fd_holder = {"fd": None}

    def set_mic(on, why=""):
        if state["mic"] == on or fd_holder["fd"] is None:
            return
        try:
            os.write(fd_holder["fd"], ftv.MIC_ON if on else ftv.MIC_OFF)
        except OSError as exc:
            log(f"!! 0xF2 write failed: {exc}")
            return
        state["mic"] = on
        log(f"mic {'ON ' if on else 'OFF'} {why}".rstrip())

    def want_mic():
        return args.always_on or state["key"] or state["capture"]

    def refresh(why=""):
        set_mic(want_mic(), why)

    def inject_assist():
        try:
            subprocess.run(["sudo", "-n", "waydroid", "shell", "--",
                            "input", "keyevent", "231"],
                           capture_output=True, timeout=10)
            log("injected KEYCODE_VOICE_ASSIST")
        except Exception as exc:
            log(f"inject failed: {exc}")

    buf = bytearray()
    stop = {"flag": False}

    def handler(signum, frame):
        stop["flag"] = True

    signal.signal(signal.SIGINT, handler)
    signal.signal(signal.SIGTERM, handler)

    fd_holder["fd"] = None
    last_dev_log = 0.0

    if args.always_on:
        state["key"] = True

    log("bridging; press the remote's mic key to talk")
    last_watch = 0.0
    last_link = 0.0
    try:
        while not stop["flag"]:
            # Connect lazily: the remote sleeps and drops off the bus, so the
            # main loop must never block waiting for it (see open_device).
            if fd_holder["fd"] is None:
                fd, info = open_device(args.device)
                if fd is None:
                    # Throttled: the remote can be absent for hours.
                    if time.monotonic() - last_dev_log > 30.0:
                        last_dev_log = time.monotonic()
                        log(f"device: not available ({info}); retrying")
                else:
                    fd_holder["fd"] = fd
                    log(f"opened {info}")
                    if want_mic():
                        state["mic"] = False
                        refresh("(connected)")

            # The link can be lost long after startup: WirePlumber restarts,
            # the loopback is recreated with a new id, or pw-cat re-attaches
            # to the default sink after an error.  A silently misrouted
            # stream plays the microphone out of the TV speakers instead of
            # feeding Android, which is not obvious until someone talks.
            if time.monotonic() - last_link > 5.0:
                last_link = time.monotonic()
                if not loop.alive():
                    # nodes vanished (or pw-loopback died): rebuild the pair
                    # and re-pin the default source, then redo the sink.
                    log("loopback: nodes gone; recreating")
                    loop.stop()
                    loop.ensure()
                    set_default_source(args.source)
                if not sink.alive() or not sink.linked():
                    log("sink: link lost; restarting pw-cat")
                    sink.restart()

            if watch and time.monotonic() - last_watch > 0.5:
                last_watch = time.monotonic()
                active = watch.active()
                if active != state["capture"]:
                    state["capture"] = active
                    log(f"android capture {'started' if active else 'stopped'}")
                    refresh("(follow-capture)")

            if fd_holder["fd"] is None:
                time.sleep(1.0)
                continue

            # Wake at least once a second even when the remote is silent.
            # The hidraw fd is blocking, so a bare os.read() would park here
            # until a report arrives and the checks above would never run.
            try:
                ready = select.select([fd_holder["fd"]], [], [], 1.0)[0]
            except OSError as exc:
                if exc.errno == errno.EINTR:
                    continue
                raise
            if not ready:
                continue

            try:
                data = os.read(fd_holder["fd"], 4096)
            except OSError as exc:
                if exc.errno in (errno.EAGAIN, errno.EINTR):
                    continue
                # remote went away (sleep / power off): drop it and let the
                # top of the loop re-open, so the supervisor keeps running.
                log(f"device: read failed ({exc}); reconnecting")
                state["mic"] = False
                try:
                    os.close(fd_holder["fd"])
                except OSError:
                    pass
                fd_holder["fd"] = None
                buf.clear()
                continue
            if not data:
                time.sleep(0.002)
                continue

            rid, payload = data[0], data[1:]
            if rid == ftv.RPT_AUDIO:
                buf.extend(payload)
                while len(buf) >= ftv.OPUS_PACKET:
                    pkt = bytes(buf[:ftv.OPUS_PACKET])
                    del buf[:ftv.OPUS_PACKET]
                    state["packets"] += 1
                    try:
                        pcm = decoder.decode(pkt)
                    except Exception as exc:
                        log(f"decode error: {exc}")
                        continue
                    state["bytes"] += len(pcm)
                    sink.write(pcm)
            elif rid == ftv.RPT_CONSUMER and len(payload) >= 2:
                usage = payload[0] | (payload[1] << 8)
                if usage == ftv.CONSUMER_VOICE_USAGE:
                    if not state["key"]:
                        state["key"] = True
                        buf.clear()
                        refresh("(voice key)")
                        if args.inject_assist:
                            inject_assist()
                elif usage == 0 and state["key"]:
                    state["key"] = False
                    buf.clear()
                    if args.keep_mic:
                        log("voice key released (mic kept on)")
                    else:
                        refresh("(voice key)")

            if args.stats:
                now = time.monotonic()
                if now - state["last_stats"] >= args.stats:
                    dt = now - state["last_stats"]
                    if state["packets"]:
                        log(f"stats: {state['packets']} pkts, "
                            f"{state['bytes']} B pcm, "
                            f"{state['packets'] / max(dt, 1e-6):.1f} pkt/s, "
                            f"mic={'on' if state['mic'] else 'off'}")
                    state["last_stats"] = now
    finally:
        if state["mic"]:
            set_mic(False, "(shutdown)")
        sink.close()
        if fd_holder["fd"] is not None:
            try:
                os.close(fd_holder["fd"])
            except OSError:
                pass
        loop.stop()
    return 0


if __name__ == "__main__":
    sys.exit(main())
