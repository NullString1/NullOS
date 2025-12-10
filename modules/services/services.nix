{ pkgs, ... }:
{
  zramSwap = {
    enable = true;
    algorithm = "zstd";
  };

  services = {
    libinput.enable = true;
    fstrim.enable = true;
    gvfs.enable = true;
    openssh.enable = true;
    blueman.enable = true;
    tumbler.enable = true;
    gnome.gnome-keyring.enable = true;
    resolved.enable = true;
    dbus.enable = true;

    smartd = {
      enable = true;
      autodetect = true;
    };

    fwupd.enable = true;

    ananicy.enable = true;
    ananicy.package = pkgs.ananicy-cpp;

    irqbalance.enable = true;
  };
}
