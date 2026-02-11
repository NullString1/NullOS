{ pkgs, vars, ... }:
{
  programs = {
    nix-ld.enable = true;
    neovim = {
      enable = vars.enableNVIM;
      defaultEditor = vars.enableNVIM;
    };
    dconf.enable = true;
    seahorse.enable = true;
    hyprland.enable = true;
    hyprlock.enable = true;
    fuse.userAllowOther = true;
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };
    direnv = {
      enable = vars.enableDirenv;
      enableZshIntegration = true;
      silent = true;
    };
    gamemode.enable = vars.enableSteam || vars.enableLutris;
  };

  environment.systemPackages = with pkgs; [
    #
    # System Tools
    #
    alsa-utils # For Alsa Mixer
    appimage-run # Needed For AppImage Support
    btop # btop like util
    brightnessctl # For Screen Brightness Control
    busybox # Provides Many Common Unix Utilities In A Single Binary
    dysk # disk usage util
    eza # Beautiful ls Replacement
    gdu # graphical disk usage
    inxi # CLI System Information Tool
    killall # For Killing All Instances Of Programs
    libnotify # For Notifications
    lm_sensors # Used For Getting Hardware Temps
    lolcat # Add Colors To Your Terminal Command Output
    lshw # Detailed Hardware Information
    ncdu # Disk Usage Analyzer With Ncurses Interface
    pavucontrol # For Editing Audio Levels & Devices
    pciutils # Collection Of Tools For Inspecting PCI Devices
    ripgrep # Improved Grep
    socat # Needed For Screenshots
    usbutils # Good Tools For USB Devices

    #
    # Development
    #
    home-manager # Home Manager CLI
    libsecret # For Storing Passwords Securely
    pkg-config # Wrapper Script For Allowing Packages To Get Info On Others

    #
    # Desktop Utilities
    #
    vars.browser # User Preferred Browser
    eog # For Image Viewing
    rhythmbox # Music Player
    teams-for-linux # Unofficial Microsoft Teams Client
    wget # Tool For Fetching Files With Links

    #
    # Multimedia
    #
    ffmpeg # Terminal Video / Audio Editing
    mesa-demos # Needed for inxi -G GPU info
    mpv # Incredible Video Player
    playerctl # Allows Changing Media Volume Through Scripts
    sox # audio support for FFMPEG

    #
    # Networking
    #
    gnome-network-displays # For Wireless Display Streaming
    qbittorrent # Torrent Client

    #
    # Gaming
    #
    moonlight-qt # NVIDIA Game Streaming Client
    wineWowPackages.waylandFull # For Running Windows Apps On Linux
  ];
}
