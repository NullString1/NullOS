{ ... }:
{
  wayland.windowManager.hyprland = {
    settings = {
      window_rule = [
        {
          name = "file-manager-tag";
          match = {
            class = "^([Tt]hunar|org.gnome.Nautilus|[Pp]cmanfm-qt|[Dd]olphin)$";
          };
          tag = "file-manager";
        }
        {
          name = "terminal-tag";
          match = {
            class = "^(com.mitchellh.ghostty|org.wezfurlong.wezterm|Alacritty|kitty|kitty-dropterm)$";
          };
          tag = "terminal";
        }
        {
          name = "brave-tag";
          match = {
            class = "^(Brave-browser(-beta|-dev|-unstable)?)$";
          };
          tag = "browser";
        }
        {
          name = "firefox-tag";
          match = {
            class = "^([Ff]irefox|org.mozilla.firefox|[Ff]irefox-esr)$";
          };
          tag = "browser";
        }
        {
          name = "chrome-tag";
          match = {
            class = "^([Gg]oogle-chrome(-beta|-dev|-unstable)?)$";
          };
          tag = "browser";
        }
        {
          name = "thorium-tag";
          match = {
            class = "^([Tt]horium-browser|[Cc]achy-browser)$";
          };
          tag = "browser";
        }
        {
          name = "zen-tag";
          match = {
            class = "^(zen-alpha)$";
          };
          tag = "browser";
        }
        {
          name = "vscodium-tag";
          match = {
            class = "^(codium|codium-url-handler|VSCodium)$";
          };
          tag = "projects";
        }
        {
          name = "vscode-tag";
          match = {
            class = "^(VSCode|code-url-handler|code)$";
          };
          tag = "projects";
        }
        {
          name = "projects-opacity";
          match = {
            tag = "projects*";
          };
          opacity = "1.0 1.0";
        }
        {
          name = "jetbrains-tag";
          match = {
            class = "^(jetbrains-.*)$";
          };
          tag = "projects";
        }
        {
          name = "android-studio-tag";
          match = {
            class = "^(android-studio)$";
          };
          tag = "projects";
        }
        {
          name = "dbgate-tag";
          match = {
            class = "^(dbgate)$";
          };
          tag = "projects";
        }
        {
          name = "httpie-tag";
          match = {
            class = "^(httpie)$";
          };
          tag = "projects";
        }
        {
          name = "discord-tag";
          match = {
            class = "^([Dd]iscord|[Ww]ebCord|[Vv]esktop)$";
          };
          tag = "im";
        }
        {
          name = "ferdium-tag";
          match = {
            class = "^([Ff]erdium)$";
          };
          tag = "im";
        }
        {
          name = "whatsapp-tag";
          match = {
            class = "^([Ww]hatsapp-for-linux)$";
          };
          tag = "im";
        }
        {
          name = "telegram-tag";
          match = {
            class = "^(org.telegram.desktop|io.github.tdesktop_x64.TDesktop)$";
          };
          tag = "im";
        }
        {
          name = "teams-tag";
          match = {
            class = "^(teams-for-linux)$";
          };
          tag = "im";
        }
        {
          name = "gamescope-tag";
          match = {
            class = "^(gamescope)$";
          };
          tag = "games";
        }
        {
          name = "steam-app-tag";
          match = {
            class = "^(steam_app_\\d+)$";
          };
          tag = "games";
        }
        {
          name = "steam-tag";
          match = {
            class = "^([Ss]team)$";
          };
          tag = "gamestore";
        }
        {
          name = "lutris-tag";
          match = {
            title = "^([Ll]utris)$";
          };
          tag = "gamestore";
        }
        {
          name = "heroic-tag";
          match = {
            class = "^(com.heroicgameslauncher.hgl)$";
          };
          tag = "gamestore";
        }
        {
          name = "bottles-tag";
          match = {
            class = "^(com.usebottles.bottles)$";
          };
          tag = "gamestore";
        }
        {
          name = "gnome-disks-tag";
          match = {
            class = "^(gnome-disks|wihotspot(-gui)?)$";
          };
          tag = "settings";
        }
        {
          name = "rofi-tag";
          match = {
            class = "^([Rr]ofi)$";
          };
          tag = "settings";
        }
        {
          name = "file-roller-tag";
          match = {
            class = "^(file-roller|org.gnome.FileRoller)$";
          };
          tag = "settings";
        }
        {
          name = "nm-applet-tag";
          match = {
            class = "^(nm-applet|nm-connection-editor|blueman-manager)$";
          };
          tag = "settings";
        }
        {
          name = "pavucontrol-tag";
          match = {
            class = "^(pavucontrol|org.pulseaudio.pavucontrol|com.saivert.pwvucontrol)$";
          };
          tag = "settings";
        }
        {
          name = "nwg-look-tag";
          match = {
            class = "^(nwg-look|qt5ct|qt6ct|[Yy]ad)$";
          };
          tag = "settings";
        }
        {
          name = "xdph-tag";
          match = {
            class = "(xdg-desktop-portal-gtk)";
          };
          tag = "settings";
        }
        {
          name = "blueman-wrapped-tag";
          match = {
            class = "(.blueman-manager-wrapped)";
          };
          tag = "settings";
        }
        {
          name = "nwg-displays-tag";
          match = {
            class = "(nwg-displays)";
          };
          tag = "settings";
        }
        {
          name = "vpn-tag";
          match = {
            class = "^(Mullvad VPN|Cloudflare Zero Trust)$";
          };
          tag = "vpn";
        }
        {
          name = "swappy-tag";
          match = {
            class = "^(swappy)$";
          };
          tag = "image-editor";
        }
        {
          name = "hyprpolkit-tag";
          match = {
            class = "^(hyprpolkitagent)$";
          };
          tag = "dialog";
        }
        {
          name = "hyprpolkit-pin";
          match = {
            class = "^(hyprpolkitagent)$";
          };
          pin = true;
        }
        {
          name = "polkit-gnome-pin";
          match = {
            class = "^(polkit-gnome-authentication-agent-1)$";
          };
          pin = true;
        }
        {
          name = "auth-pin";
          match = {
            title = "^(Authentication Required)$";
          };
          pin = true;
        }
        {
          name = "policykit-pin";
          match = {
            title = "^(Policy Kit)$";
          };
          pin = true;
        }
        {
          name = "open-file-dialog";
          match = {
            title = "^(Open File)$";
          };
          tag = "dialog";
        }
        {
          name = "select-file-dialog";
          match = {
            title = "^(Select a File)$";
          };
          tag = "dialog";
        }
        {
          name = "wallpaper-dialog";
          match = {
            title = "^(Choose wallpaper)$";
          };
          tag = "dialog";
        }
        {
          name = "open-folder-dialog";
          match = {
            title = "^(Open Folder)$";
          };
          tag = "dialog";
        }
        {
          name = "save-as-dialog";
          match = {
            title = "^(Save As)$";
          };
          tag = "dialog";
        }
        {
          name = "library-dialog";
          match = {
            title = "^(Library)$";
          };
          tag = "dialog";
        }
        {
          name = "file-upload-dialog";
          match = {
            title = "^(File Upload)$";
          };
          tag = "dialog";
        }
        {
          name = "xdph-dialog";
          match = {
            class = "^(xdg-desktop-portal-gtk)$";
          };
          tag = "dialog";
        }
        {
          name = "settings-float";
          match = {
            tag = "settings*";
          };
          float = true;
          size = "70% 70%";
          center = true;
        }
        {
          name = "dialog-float";
          match = {
            tag = "dialog*";
          };
          float = true;
          center = true;
          size = "60% 60%";
        }
        {
          name = "vpn-float";
          match = {
            tag = "vpn*";
          };
          float = true;
          size = "300 400";
          move = "75% 5%";
        }
        {
          name = "mullvad-special";
          match = {
            class = "^(Mullvad VPN)$";
          };
          workspace = "special";
        }
        {
          name = "steam-extras-float";
          match = {
            tag = "steam-extras*";
          };
          float = true;
          center = true;
        }
        {
          name = "image-editor-float";
          match = {
            tag = "image-editor*";
          };
          float = true;
          center = true;
        }
        {
          name = "games-no-blur";
          match = {
            tag = "games*";
          };
          no_blur = true;
          no_shadow = true;
          immediate = true;
          fullscreen = true;
        }
        {
          name = "pip";
          match = {
            title = "^(Picture-in-Picture)$";
          };
          float = true;
          pin = true;
          center = false;
          move = "72% 7%";
          keep_aspect_ratio = true;
          opacity = "0.95 0.75";
        }
        {
          name = "libreoffice-splash";
          match = {
            class = "^(libreoffice.*)$";
            title = "^(SPLASH)$";
          };
          float = true;
        }
        {
          name = "libreoffice-dialog";
          match = {
            class = "^(libreoffice.*)$";
            title = "^(.*Dialog.*)$";
          };
          float = true;
          center = true;
        }
        {
          name = "sharing-indicator";
          match = {
            title = "^(.*Sharing Indicator)$";
          };
          float = true;
          move = "0 0";
          no_focus = true;
        }
        {
          name = "thunar-dialog-hack";
          match = {
            class = "([Tt]hunar)";
            title = "negative:.*[Tt]hunar.*";
          };
          float = true;
          center = true;
        }
        {
          name = "heroic-dialog-hack";
          match = {
            class = "^(com.heroicgameslauncher.hgl)$";
            title = "negative:Heroic Games Launcher";
          };
          float = true;
        }
        {
          name = "steam-dialog-hack";
          match = {
            class = "^([Ss]team)$";
            title = "negative:^([Ss]team)$";
          };
          float = true;
        }
        {
          name = "vscodium-dialog-hack";
          match = {
            class = "(codium|codium-url-handler|VSCodium)";
            title = "negative:.*(codium|VSCodium).*";
          };
          float = true;
        }
        {
          name = "waypaper-float";
          match = {
            class = "^([Ww]aypaper)$";
          };
          float = true;
        }
        {
          name = "mpv-float";
          match = {
            class = "^(mpv|com.github.rafostar.Clapper)$";
          };
          float = true;
        }
        {
          name = "auth-float";
          match = {
            title = "^(Authentication Required)$";
          };
          float = true;
          center = true;
        }
        {
          name = "add-folder-float";
          match = {
            initial_title = "(Add Folder to Workspace)";
          };
          float = true;
          size = "70% 60%";
        }
        {
          name = "open-files-float";
          match = {
            initial_title = "(Open Files)";
          };
          float = true;
          size = "70% 60%";
        }
        {
          name = "save-float";
          match = {
            initial_title = "(wants to save)";
          };
          float = true;
        }
        {
          name = "ferdium-float";
          match = {
            class = "^([Ff]erdium)$";
          };
          float = true;
          center = true;
          size = "60% 70%";
        }
        {
          name = "idle-inhibit";
          match = {
            class = ".*";
          };
          idle_inhibit = "fullscreen";
        }
        {
          name = "browser-opacity";
          match = {
            tag = "browser*";
          };
          opacity = "1.0 1.0";
        }
        {
          name = "im-opacity";
          match = {
            tag = "im*";
          };
          opacity = "0.94 0.86";
        }
        {
          name = "file-manager-opacity";
          match = {
            tag = "file-manager*";
          };
          opacity = "0.9 0.8";
        }
        {
          name = "terminal-opacity";
          match = {
            tag = "terminal*";
          };
          opacity = "0.8 0.7";
          size = "80% 80%";
        }
        {
          name = "settings-opacity";
          match = {
            tag = "settings*";
          };
          opacity = "0.8 0.7";
        }
        {
          name = "gedit-opacity";
          match = {
            class = "^(gedit|org.gnome.TextEditor|mousepad)$";
          };
          opacity = "0.8 0.7";
        }
        {
          name = "seahorse-opacity";
          match = {
            class = "^(seahorse)$";
          };
          opacity = "0.9 0.8";
        }
        {
          name = "eog-float";
          match = {
            class = "^(eog)$";
          };
          float = true;
          center = true;
        }
        {
          name = "jetbrains-welcome-float";
          match = {
            class = "^(jetbrains-.*)$";
            title = "^(Welcome to.*)$";
          };
          float = true;
          center = true;
        }
        {
          name = "android-studio-welcome-float";
          match = {
            class = "^(android-studio)$";
            title = "^(Welcome to.*)$";
          };
          float = true;
        }
        {
          name = "android-studio-emulator-float";
          match = {
            class = "^(android-studio)$";
            title = "^(Emulator.*)$";
          };
          float = true;
        }
        {
          name = "wine-splash-float";
          match = {
            class = "^(wine)$";
            title = "^(Splash)$";
          };
          float = true;
        }
        {
          name = "wine-fusion-float";
          match = {
            class = "^(wine)$";
            title = "^(Fusion 360)$";
          };
          float = true;
        }
        {
          name = "dolphin-properties-float";
          match = {
            class = "^(org.kde.dolphin)$";
            title = "^(Properties for.*)$";
          };
          float = true;
        }
        {
          name = "dolphin-progress-float";
          match = {
            class = "^(org.kde.dolphin)$";
            title = "^(Copying|Moving|Deleting|Progress)$";
          };
          float = true;
        }
        {
          name = "qbittorrent-tag";
          match = {
            class = "^(org.qbittorrent.qBittorrent)$";
          };
          tag = "downloads";
        }
        {
          name = "qbittorrent-add-float";
          match = {
            class = "^(org.qbittorrent.qBittorrent)$";
            title = "^(Add Torrent Files)$";
          };
          float = true;
        }
        {
          name = "qbittorrent-options-float";
          match = {
            class = "^(org.qbittorrent.qBittorrent)$";
            title = "^(Options)$";
          };
          float = true;
        }
        {
          name = "moonlight-tag";
          match = {
            class = "^(moonlight)$";
          };
          tag = "games";
        }
        {
          name = "suppress-maximize";
          match = {
            class = ".*";
          };
          suppress_event = "maximize";
        }
        {
          name = "fix-xwayland-drags";
          match = {
            class = "^$";
            title = "^$";
            xwayland = true;
          };
          float = true;
          no_focus = true;
          fullscreen = false;
          pin = false;
        }
      ];
    };
  };
}
