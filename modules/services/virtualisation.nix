{
  pkgs,
  vars,
  ...
}:
{
  virtualisation = {
    docker.enable = vars.enableDocker;
    libvirtd = {
      enable = true;
    };
  };
  environment.systemPackages = if vars.enableDocker then [ pkgs.docker-compose ] else [ ];
  users.extraGroups.vboxusers.members = [ vars.username ];

  programs = {
    virt-manager.enable = true;
  };

}
