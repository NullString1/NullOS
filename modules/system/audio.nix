{ vars, lib, ... }:
{
  services = {
    pipewire = lib.mkIf vars.enableAudio {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;
    };
  };
}
