{
  pkgs,
  vars,
  lib,
  ...
}:
{
  environment.systemPackages = lib.optionals vars.enableGnomeNetworkDisplays [
    pkgs.gst_all_1.gst-plugins-base
    pkgs.gst_all_1.gst-plugins-good
    pkgs.gst_all_1.gst-libav
    pkgs.gst_all_1.gst-plugins-bad
    pkgs.gst_all_1.gst-plugins-ugly
    pkgs.gst_all_1.gst-vaapi
    pkgs.gst_all_1.gstreamer
    pkgs.gnome-network-displays
  ];

  services.gnome.glib-networking.enable = vars.enableGnomeNetworkDisplays;  
}
