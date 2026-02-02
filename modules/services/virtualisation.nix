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
  environment.systemPackages = pkgs.lib.mkIf vars.enableDocker [ pkgs.docker-compose ];
  users.extraGroups.vboxusers.members = [ vars.username ];

  programs = {
    virt-manager.enable = true;
  };

}
