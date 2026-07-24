{
  pkgs,
  vars,
  ...
}:
{
  virtualisation = {
    docker = {
      enable = vars.enableDocker;
      daemon.settings = {
        fixed-cidr-v6 = "fd00::/80";
        ipv6 = true;
      };
    };
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
