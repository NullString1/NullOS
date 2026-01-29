{ pkgs, ... }:
{
  home.packages = [
    (pkgs.lutris.override {
      extraPkgs = pkgs: [
        pkgs.vulkan-loader
        pkgs.vulkan-tools
        pkgs.vulkan-headers
        pkgs.glib-networking
        pkgs.gnutls
      ];
    })
  ];
}
