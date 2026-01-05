{
  vars,
  ...
}:
{
  virtualisation = {
    docker.enable = true;
    podman.enable = false;
    libvirtd = {
      enable = true;
    };
  };
  users.extraGroups.vboxusers.members = [ vars.username ];

  programs = {
    virt-manager.enable = true;
  };

}
