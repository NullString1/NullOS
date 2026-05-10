{
  pkgs,
  vars,
  ...
}:
{
  virtualisation = {
    docker.enable = vars.enableDocker;
    libvirtd = {
      enable = false;
    };
  };
  environment.systemPackages = pkgs.lib.mkIf vars.enableDocker [ pkgs.docker-compose ];
  users.extraGroups.vboxusers.members = [ vars.username ];

  programs = {
    virt-manager.enable = false;
  };

}
