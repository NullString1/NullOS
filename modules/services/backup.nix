{
  pkgs,
  vars,
  config,
  ...
}:
let
  mkHomeExcludes = paths: map (path: "/home/${vars.username}/${path}") paths;
  expand =
    str:
    let
      m = builtins.match "(.*)[{]([^}]+)[}](.*)" str;
    in
    if m == null then
      [ str ]
    else
      let
        prefix = builtins.elemAt m 0;
        options = builtins.filter builtins.isString (builtins.split "," (builtins.elemAt m 1));
        suffix = builtins.elemAt m 2;
      in
      builtins.concatMap (opt: expand "${prefix}${opt}${suffix}") options;
  homeExcludes = [
    ".arduino15"
    ".bubblewrap"
    ".minecraft"
    ".lunarclient"
    ".bun"
    ".net"
    ".javacpp"
    ".objection"
    ".gemini"
    ".winboat"
    ".nv"
    ".platformio"
    ".rustup"
    ".wine"
    "nixpkgs"
    ".cache"
    ".npm"
    ".android"
    ".cargo"
    ".gradle"
    ".nix-defexpr"
    ".ServiceHub"
    ".skiko"
    ".stremio-server"
    ".templateengine"
    ".var"
    "Android"
    ".local"
    ".BurpSuite"
    ".bash_history"
    ".config"
    ".dotnet"
    ".ipython"
    ".java"
    ".vscode"
    "winboat"
    ".autodesk_fusion"
    "Games"
    "Downloads/*.iso"
    "Downloads/.npm"
  ];
in
{
  services.restic.backups.nsdata = {
    paths = [
      "/mdata"
      "/home/${vars.username}"
    ];
    repositoryFile = config.sops.secrets.resticRepository.path;
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
    exclude = pkgs.lib.flatten [
      (mkHomeExcludes homeExcludes)
      (expand "/mdata/**/openwrt/{build_dir,staging_dir,dl,tmp,feeds}")
      "/mdata/**/target"
      "/mdata/**/.direnv"
      "**/node_modules"
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
