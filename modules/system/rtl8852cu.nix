{
  lib,
  stdenv,
  fetchFromGitHub,
  kernel,
  bc,
  nukeReferences,
}:

stdenv.mkDerivation {
  pname = "rtl8852cu";
  version = "20240510";

  src = fetchFromGitHub {
    owner = "morrownr";
    repo = "rtl8852cu-20240510";
    rev = "c01bd409ddce75822cd9127ac1a97ba4fd31a9d8";
    hash = "sha256-yp5e2ijkqKji+dJ+XPMJJPhkjh5NYUiFEncQc4HdNEA=";
  };

  postPatch = ''
    # --- 1. Patch Makefile for Nix environment ---
    substituteInPlace ./Makefile \
      --replace-fail /sbin/depmod \# \
      --replace-fail '$(MODDESTDIR)' "$out/lib/modules/${kernel.modDirVersion}/kernel/net/wireless/" \
      --replace-fail 'cp -f $(MODULE_NAME).conf /etc/modprobe.d' \
      'mkdir -p $out/etc/modprobe.d && cp -f $(MODULE_NAME).conf $out/etc/modprobe.d' \
      --replace-fail "sh edit-options.sh" ""
    substituteInPlace ./platform/i386_pc.mk \
      --replace-fail /lib/modules "${kernel.dev}/lib/modules"

    # Fix crypto function name conflicts with kernel 6.18+
    # Use sed for more reliable multi-line replacements
    sed -i 's/\bhmac_sha256_vector\b/rtw_hmac_sha256_vector/g' ./core/crypto/sha256.h
    sed -i 's/\bhmac_sha256\b/rtw_hmac_sha256/g' ./core/crypto/sha256.h
    sed -i 's/\bsha256_prf\b/rtw_sha256_prf/g' ./core/crypto/sha256.h

    sed -i 's/\bhmac_sha256_vector\b/rtw_hmac_sha256_vector/g' ./core/crypto/sha256.c
    sed -i 's/\bhmac_sha256\b/rtw_hmac_sha256/g' ./core/crypto/sha256.c

    sed -i 's/\bsha256_prf\b/rtw_sha256_prf/g' ./core/crypto/sha256-prf.c
    sed -i 's/\bhmac_sha256_vector\b/rtw_hmac_sha256_vector/g' ./core/crypto/sha256-prf.c

    sed -i 's/\bsha256_prf\b/rtw_sha256_prf/g' ./core/rtw_swcrypto.c
  '';

  nativeBuildInputs = [
    bc
    nukeReferences
  ]
  ++ kernel.moduleBuildDependencies;

  hardeningDisable = [
    "pic"
    "format"
  ];

  makeFlags = [
    "ARCH=${stdenv.hostPlatform.linuxArch}"
    ("CONFIG_PLATFORM_I386_PC=" + (if stdenv.hostPlatform.isx86 then "y" else "n"))
    ("CONFIG_PLATFORM_ARM_RPI=" + (if stdenv.hostPlatform.isAarch then "y" else "n"))
  ]
  ++ lib.optionals (stdenv.hostPlatform != stdenv.buildPlatform) [
    "CROSS_COMPILE=${stdenv.cc.targetPrefix}"
  ];

  preInstall = ''
    mkdir -p "$out/lib/modules/${kernel.modDirVersion}/kernel/net/wireless/"
    mkdir -p "$out/usr/lib/systemd/system-sleep"
  '';

  postInstall = ''
    nuke-refs $out/lib/modules/*/kernel/net/wireless/*.ko
  '';

  env.NIX_CFLAGS_COMPILE = "-Wno-designated-init";
  enableParallelBuilding = true;

  meta = with lib; {
    description = "Driver for Realtek RTL8852CU (802.11ax) USB Wi-Fi adapter";
    platforms = platforms.linux;
    license = licenses.gpl2;
  };
}
