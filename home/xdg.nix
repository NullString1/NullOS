{ pkgs, ... }:
{
  xdg = {
    enable = true;
    mime.enable = true;
    configFile."mimeapps.list".force = true;
    configFile."mimeapps.list".text = ''
      [Default Applications]
      text/plain=nvim.desktop
      text/markdown=code.desktop
      text/xml=nvim.desktop
      text/css=nvim.desktop
      text/javascript=code.desktop
      application/json=nvim.desktop
      application/x-yaml=nvim.desktop
      application/pdf=brave-browser.desktop
      application/epub+zip=brave-browser.desktop
      image/png=org.gnome.eog.desktop
      image/jpeg=org.gnome.eog.desktop
      image/jpg=org.gnome.eog.desktop
      image/gif=org.gnome.eog.desktop
      image/webp=org.gnome.eog.desktop
      image/svg+xml=org.gnome.eog.desktop
      image/bmp=org.gnome.eog.desktop
      image/x-icon=org.gnome.eog.desktop
      video/mp4=mpv.desktop
      video/x-matroska=mpv.desktop
      video/webm=mpv.desktop
      video/mpeg=mpv.desktop
      video/x-msvideo=mpv.desktop
      video/quicktime=mpv.desktop
      audio/mpeg=org.gnome.Rhythmbox3.desktop
      audio/mp3=org.gnome.Rhythmbox3.desktop
      audio/mp4=org.gnome.Rhythmbox3.desktop
      audio/x-m4a=org.gnome.Rhythmbox3.desktop
      audio/flac=org.gnome.Rhythmbox3.desktop
      audio/x-flac=org.gnome.Rhythmbox3.desktop
      audio/ogg=org.gnome.Rhythmbox3.desktop
      audio/x-vorbis+ogg=org.gnome.Rhythmbox3.desktop
      audio/wav=org.gnome.Rhythmbox3.desktop
      application/x-bittorrent=org.qbittorrent.qBittorrent.desktop
      x-scheme-handler/magnet=org.qbittorrent.qBittorrent.desktop
      application/x-appimage=appimage-run.desktop
      application/vnd.oasis.opendocument.text=writer.desktop
      application/vnd.oasis.opendocument.spreadsheet=calc.desktop
      application/vnd.oasis.opendocument.presentation=impress.desktop
      application/vnd.oasis.opendocument.graphics=draw.desktop
      application/vnd.openxmlformats-officedocument.wordprocessingml.document=writer.desktop
      application/vnd.openxmlformats-officedocument.spreadsheetml.sheet=calc.desktop
      application/vnd.openxmlformats-officedocument.presentationml.presentation=impress.desktop
      application/msword=writer.desktop
      application/vnd.ms-excel=calc.desktop
      application/vnd.ms-powerpoint=impress.desktop
      application/rtf=writer.desktop
      text/csv=calc.desktop
      inode/directory=org.kde.dolphin.desktop
      x-scheme-handler/http=brave-browser.desktop
      x-scheme-handler/https=brave-browser.desktop
      x-scheme-handler/ftp=brave-browser.desktop
      x-scheme-handler/chrome=brave-browser.desktop
      text/html=brave-browser.desktop
      application/x-extension-htm=brave-browser.desktop
      application/x-extension-html=brave-browser.desktop
      application/x-extension-shtml=brave-browser.desktop
      application/xhtml+xml=brave-browser.desktop
      application/x-extension-xhtml=brave-browser.desktop
      application/x-extension-xht=brave-browser.desktop
      application/zip=org.kde.dolphin.desktop
      application/x-tar=org.kde.dolphin.desktop
      application/x-compressed-tar=org.kde.dolphin.desktop
      application/x-7z-compressed=org.kde.dolphin.desktop
      application/x-rar=org.kde.dolphin.desktop
      application/vnd.sqlite3=dbgate.desktop
      application/x-sqlite3=dbgate.desktop

      [Added Associations]
    '';
    mimeApps = {
      enable = false;
      defaultApplications = {
        "text/plain" = [ "nvim.desktop" ];
        "text/markdown" = [ "code.desktop" ];
        "text/xml" = [ "nvim.desktop" ];
        "text/css" = [ "nvim.desktop" ];
        "text/javascript" = [ "code.desktop" ];
        "application/json" = [ "nvim.desktop" ];
        "application/x-yaml" = [ "nvim.desktop" ];

        "application/pdf" = [ "brave-browser.desktop" ];
        "application/epub+zip" = [ "brave-browser.desktop" ];

        "image/png" = [ "org.gnome.eog.desktop" ];
        "image/jpeg" = [ "org.gnome.eog.desktop" ];
        "image/jpg" = [ "org.gnome.eog.desktop" ];
        "image/gif" = [ "org.gnome.eog.desktop" ];
        "image/webp" = [ "org.gnome.eog.desktop" ];
        "image/svg+xml" = [ "org.gnome.eog.desktop" ];
        "image/bmp" = [ "org.gnome.eog.desktop" ];
        "image/x-icon" = [ "org.gnome.eog.desktop" ];

        "video/mp4" = [ "mpv.desktop" ];
        "video/x-matroska" = [ "mpv.desktop" ];
        "video/webm" = [ "mpv.desktop" ];
        "video/mpeg" = [ "mpv.desktop" ];
        "video/x-msvideo" = [ "mpv.desktop" ];
        "video/quicktime" = [ "mpv.desktop" ];

        "audio/mpeg" = [ "org.gnome.Rhythmbox3.desktop" ];
        "audio/mp3" = [ "org.gnome.Rhythmbox3.desktop" ];
        "audio/mp4" = [ "org.gnome.Rhythmbox3.desktop" ];
        "audio/x-m4a" = [ "org.gnome.Rhythmbox3.desktop" ];
        "audio/flac" = [ "org.gnome.Rhythmbox3.desktop" ];
        "audio/x-flac" = [ "org.gnome.Rhythmbox3.desktop" ];
        "audio/ogg" = [ "org.gnome.Rhythmbox3.desktop" ];
        "audio/x-vorbis+ogg" = [ "org.gnome.Rhythmbox3.desktop" ];
        "audio/wav" = [ "org.gnome.Rhythmbox3.desktop" ];

        "application/x-bittorrent" = [ "org.qbittorrent.qBittorrent.desktop" ];
        "x-scheme-handler/magnet" = [ "org.qbittorrent.qBittorrent.desktop" ];

        "application/x-appimage" = [ "appimage-run.desktop" ];

        "application/vnd.oasis.opendocument.text" = [ "writer.desktop" ];
        "application/vnd.oasis.opendocument.spreadsheet" = [ "calc.desktop" ];
        "application/vnd.oasis.opendocument.presentation" = [ "impress.desktop" ];
        "application/vnd.oasis.opendocument.graphics" = [ "draw.desktop" ];
        "application/vnd.openxmlformats-officedocument.wordprocessingml.document" = [ "writer.desktop" ];
        "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet" = [ "calc.desktop" ];
        "application/vnd.openxmlformats-officedocument.presentationml.presentation" = [ "impress.desktop" ];
        "application/msword" = [ "writer.desktop" ];
        "application/vnd.ms-excel" = [ "calc.desktop" ];
        "application/vnd.ms-powerpoint" = [ "impress.desktop" ];
        "application/rtf" = [ "writer.desktop" ];
        "text/csv" = [ "calc.desktop" ];

        "inode/directory" = [ "org.kde.dolphin.desktop" ];

        "x-scheme-handler/http" = [ "brave-browser.desktop" ];
        "x-scheme-handler/https" = [ "brave-browser.desktop" ];
        "x-scheme-handler/ftp" = [ "brave-browser.desktop" ];
        "x-scheme-handler/chrome" = [ "brave-browser.desktop" ];
        "text/html" = [ "brave-browser.desktop" ];
        "application/x-extension-htm" = [ "brave-browser.desktop" ];
        "application/x-extension-html" = [ "brave-browser.desktop" ];
        "application/x-extension-shtml" = [ "brave-browser.desktop" ];
        "application/xhtml+xml" = [ "brave-browser.desktop" ];
        "application/x-extension-xhtml" = [ "brave-browser.desktop" ];
        "application/x-extension-xht" = [ "brave-browser.desktop" ];

        "application/zip" = [ "org.kde.dolphin.desktop" ];
        "application/x-tar" = [ "org.kde.dolphin.desktop" ];
        "application/x-compressed-tar" = [ "org.kde.dolphin.desktop" ];
        "application/x-7z-compressed" = [ "org.kde.dolphin.desktop" ];
        "application/x-rar" = [ "org.kde.dolphin.desktop" ];

        "application/vnd.sqlite3" = [ "dbgate.desktop" ];
        "application/x-sqlite3" = [ "dbgate.desktop" ];
      };
    };
    portal = {
      enable = true;
      extraPortals = [
        pkgs.xdg-desktop-portal-hyprland
        pkgs.xdg-desktop-portal-gtk
        pkgs.kdePackages.xdg-desktop-portal-kde
      ];
      configPackages = [ pkgs.hyprland ];
    };
  };
}
