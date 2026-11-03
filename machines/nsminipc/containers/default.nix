{
  # Source used the docker backend explicitly; nixpkgs defaults
  # oci-containers to podman, so pin docker to match the repo's
  # docker daemon (data-root=/hdd/docker).
  virtualisation.oci-containers.backend = "docker";
  imports = [
    ./homeassistant.nix
    ./cloudflared.nix
    ./matter-hub.nix
    ./postgres.nix
    # ./evolution-api.nix
  ];
}
