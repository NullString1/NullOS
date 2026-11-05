{
  pkgs,
  ...
}:
let
  # Fire TV BLE remote microphone -> PipeWire virtual microphone.
  #
  # Waydroid's audio HAL (audio.primary.waydroid.so) opens the ALSA device named
  # "pulse" with PULSE_RUNTIME_PATH pointing at the host PulseAudio socket, so
  # Android's "Built-In Mic" is simply the host's default source. The bridge
  # decodes the remote's 0xF0 Opus stream into a pw-loopback sink and pins the
  # matching source as default, which makes Assistant/katniss hear the remote
  # exactly like FireOS does.
  #
  # This lives in its own module on purpose: it is imported by waydroid.nix,
  # and keeping the derivation out of that file means editing the bridge no
  # longer changes waydroid-container.service. A change there restarts the
  # container, which tears down the Android session and with it the TV UI.
  firetv-mic-bridge = pkgs.stdenvNoCC.mkDerivation {
    pname = "firetv-mic-bridge";
    version = "1.0";
    src = ./.;
    nativeBuildInputs = [ pkgs.makeWrapper ];
    dontBuild = true;
    installPhase = ''
      runHook preInstall
      mkdir -p $out/bin
      cp ftv_mic_bridge.py ftv_remote.py $out/bin/
      chmod +x $out/bin/ftv_mic_bridge.py
      patchShebangs $out/bin
      makeWrapper ${pkgs.python3}/bin/python3 $out/bin/firetv-mic-bridge \
        --add-flags "$out/bin/ftv_mic_bridge.py" \
        --set FTV_LIBOPUS ${pkgs.libopus}/lib/libopus.so.0
      runHook postInstall
    '';
  };
in
{
  # Runs inside the cage user session, where XDG_RUNTIME_DIR/pipewire live and
  # /dev/hidraw0 is uaccess-granted. Deliberately not added to
  # environment.systemPackages: that would rebuild system-path on every bridge
  # change and drag unrelated units through a restart.
  systemd.user.services.firetv-mic-bridge = {
    description = "Fire TV BLE remote microphone -> PipeWire virtual mic";
    wantedBy = [ "default.target" ];
    wants = [
      "pipewire.service"
      "wireplumber.service"
    ];
    after = [
      "pipewire.service"
      "wireplumber.service"
    ];
    serviceConfig = {
      ExecStart = "${firetv-mic-bridge}/bin/firetv-mic-bridge --follow-capture";
      Restart = "always";
      RestartSec = 3;
      # /run/wrappers/bin/sudo is needed to inject KEYCODE_VOICE_ASSIST
      # into Waydroid (the remote's voice key is not mapped in Android).
      Environment = [
        "PATH=/run/wrappers/bin:/run/current-system/sw/bin:${pkgs.pipewire}/bin"
      ];
    };
  };
}
