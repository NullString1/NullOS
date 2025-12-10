{
  vars,
  ...
}:
{
  virtualisation = {
    docker.enable = true;
    podman.enable = false;
    libvirtd = {
      enable = false;
    };
  };
  users.extraGroups.vboxusers.members = [ vars.username ];

  programs = {
    virt-manager.enable = false;
  };

}
