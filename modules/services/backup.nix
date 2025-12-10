{
  vars,
  ...
}:
{
  services.restic.backups.nsdata = {
    paths = [
      "/mdata"
      "/home/${vars.username}"
    ];
    repository = "${vars.resticRepository}";
    passwordFile = "/etc/nixos/restic-password";
    user = "${vars.username}";
    extraOptions = [ "--exclude-caches" ];
    pruneOpts = [
      "--keep-last 10"
      "--keep-daily 7"
      "--keep-weekly 4"
      "--keep-monthly 6"
    ];
    initialize = true;
    runCheck = true;
    exclude = [
      "/home/${vars.username}/.arduino15"
      "/home/${vars.username}/.platformio"
      "/home/${vars.username}/.rustup"
      "/home/${vars.username}/.wine"
      "/home/${vars.username}/nixpkgs"
      "/home/${vars.username}/.cache"
      "/home/${vars.username}/.android"
      "/home/${vars.username}/.cargo"
      "/home/${vars.username}/.gradle"
      "/home/${vars.username}/.nix-defexpr"
      "/home/${vars.username}/.ServiceHub"
      "/home/${vars.username}/.skiko"
      "/home/${vars.username}/.stremio-server"
      "/home/${vars.username}/.templateengine"
      "/home/${vars.username}/.var"
      "/home/${vars.username}/Android"
      "/home/${vars.username}/.local"
      "/home/${vars.username}/.BurpSuite"
      "/home/${vars.username}/.bash_history"
      "/home/${vars.username}/.config"
      "/home/${vars.username}/.dotnet"
      "/home/${vars.username}/.ipython"
      "/home/${vars.username}/.java"
      "/home/${vars.username}/.vscode"
      "/mdata/**/openwrt/build_dir" # openwrt builddir
      "/mdata/**/target" # cargo builds
      "**/node_modules" # node modules
      "/mdata/**/.direnv" # direnv cache
      "**/ipch"
      "**/.venv"
      ".trash/"
    ];
    timerConfig = {
      OnBootSec = "1m";
      OnUnitActiveSec = "1h";
    };
  };
  systemd.services.restic-backups-nsdata.serviceConfig = {
    Nice = 19;
    IOSchedulingClass = "best-effort";
    IOSchedulingPriority = 7;
  };
}
