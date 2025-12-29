{ pkgs, vars, ... }:
{
  programs = {
    neovim = {
      enable = true;
      defaultEditor = true;
    };
    dconf.enable = true;
    seahorse.enable = true;
    hyprland.enable = true;
    hyprlock.enable = true;
    fuse.userAllowOther = true;
    adb.enable = true;
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };
    direnv = {
      enable = true;
      enableZshIntegration = true;
      silent = true;
    };
    gamemode.enable = true;
  };

  environment.systemPackages = with pkgs; [
    dbgate # SQL GUI
    home-manager
    p7zip # For Handling .7z Files
    binwalk # For Analyzing Binary Files
    hexdump # For Viewing Binary Files
    alsa-utils # For Alsa Mixer
    appimage-run # Needed For AppImage Support
    btop # btop like util
    vars.browser # User Preferred Browser
    obsidian # Note Taking App
    openfortivpn # Fortinet VPN Client
    brightnessctl # For Screen Brightness Control
    docker-compose # Allows Controlling Docker From A Single File
    dysk # disk usage util
    eza # Beautiful ls Replacement
    ffmpeg # Terminal Video / Audio Editing
    gdu # graphical disk usage
    mesa-demos # Needed for inxi -G GPU info
    eog # For Image Viewing
    inxi # CLI System Information Tool
    killall # For Killing All Instances Of Programs
    libnotify # For Notifications
    lm_sensors # Used For Getting Hardware Temps
    lolcat # Add Colors To Your Terminal Command Output
    lshw # Detailed Hardware Information
    mpv # Incredible Video Player
    ncdu # Disk Usage Analyzer With Ncurses Interface
    nixfmt-rfc-style # Nix Formatter
    pavucontrol # For Editing Audio Levels & Devices
    pciutils # Collection Of Tools For Inspecting PCI Devices
    pkg-config # Wrapper Script For Allowing Packages To Get Info On Others
    playerctl # Allows Changing Media Volume Through Scripts
    rhythmbox # Music Player
    ripgrep # Improved Grep
    socat # Needed For Screenshots
    sox # audio support for FFMPEG
    unrar # Tool For Handling .rar Files
    unzip # Tool For Handling .zip Files
    usbutils # Good Tools For USB Devices
    busybox # Provides Many Common Unix Utilities In A Single Binary
    wget # Tool For Fetching Files With Links
    hyprpaper # Wallpaper Setter For Hyprland
    qbittorrent # Torrent Client
    libsecret # For Storing Passwords Securely
    teams-for-linux # Unofficial Microsoft Teams Client
    waypipe # For Running Wayland Apps Over SSH
    moonlight-qt # NVIDIA Game Streaming Client
    gnome-network-displays
    gst_all_1.gstreamer
    gst_all_1.gst-plugins-base
    gst_all_1.gst-plugins-good
    gst_all_1.gst-plugins-bad
    gst_all_1.gst-plugins-ugly
    gst_all_1.gst-libav
    # Needed specifically for the "x264enc" and "fdkaacenc" mentioned in your logs
    gst_all_1.gst-vaapi
  ];
}
