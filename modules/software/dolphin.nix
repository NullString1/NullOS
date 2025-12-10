{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    ffmpegthumbnailer
    kdePackages.dolphin
  ];
}
