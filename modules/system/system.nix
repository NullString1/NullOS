{ vars, ... }:
let
  lowPriority = {
    Nice = 19;
    IOSchedulingClass = "idle";
    IOSchedulingPriority = 7;
  };
in
{
  nix = {
    settings = {
      download-buffer-size = 512000000; # 512 MB
      auto-optimise-store = true;
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      substituters = [
        "https://hyprland.cachix.org"
        "https://cache.nixos.org"
        "https://nix-community.cachix.org"
        "https://logsmart-cache.cachix.org"
      ];
      trusted-public-keys = [
        "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "logsmart-cache.cachix.org-1:nhxeVYtlgc5IZ+6zALnIT/6PdZQHpjPwV+R0qwjm+BQ="
      ];
      trusted-users = [ vars.username ];
      access-tokens = vars.access-tokens;
    };
    optimise = {
      automatic = true;
    };
  };
  time.timeZone = "${vars.timeZone}";
  i18n.defaultLocale = "${vars.locale}";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "${vars.locale}";
    LC_IDENTIFICATION = "${vars.locale}";
    LC_MEASUREMENT = "${vars.locale}";
    LC_MONETARY = "${vars.locale}";
    LC_NAME = "${vars.locale}";
    LC_NUMERIC = "${vars.locale}";
    LC_PAPER = "${vars.locale}";
    LC_TELEPHONE = "${vars.locale}";
    LC_TIME = "${vars.locale}";
    LC_ALL = "${vars.locale}";
  };
  console.keyMap = "${vars.consoleKeyMap}";
  system = {
    stateVersion = "25.11";
    autoUpgrade = {
      enable = true;
      flake = "/mdata/NS/NullOS";
      runGarbageCollection = true;
    };
  };
  systemd.services.nixos-upgrade.serviceConfig = lowPriority;
  systemd.services.nix-optimise.serviceConfig = lowPriority;
}
