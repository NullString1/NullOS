{
  pkgs,
  lib,
  vars,
  ...
}:
{
  zramSwap = {
    enable = true;
    algorithm = "zstd";
  };

  services = {
    libinput.enable = true;
    fstrim.enable = true;
    gvfs.enable = true;
    openssh = {
      enable = true;
      settings = {
        PermitRootLogin = "no";
        MaxAuthTries = 3;
      };
    };
    blueman.enable = vars.enableBluetooth;
    tumbler.enable = true;
    gnome.gnome-keyring.enable = true;
    resolved.enable = true;
    dbus.enable = true;

    smartd = {
      enable = true;
      autodetect = true;
    };

    fwupd.enable = true;

    ananicy = {
      enable = vars.isHyprland || vars.isKDE;
      package = pkgs.ananicy-cpp;
      rulesProvider = pkgs.ananicy-rules-cachyos;
    };

    irqbalance.enable = true;
    earlyoom = {
      enable = true;
      enableNotifications = true;
    };
    systembus-notify.enable = true;
    fail2ban = {
      enable = true;
      ignoreIP = [
        "127.0.0.1/8"
        "::1"
      ];
    };
    avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
      settings.publish = {
        publish-addresses = true;
        publish-workstation = true;
      };
    };
  };
  security.pam.services = lib.mkIf vars.enableWayVNC {
    wayvnc = { };
  };
}
