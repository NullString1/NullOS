{ ... }:
{
  wayland.windowManager.hyprland = {
    settings = {
      windowrule = [
        # -----------------------------------------------------
        # 1. TAGGING (Categorize apps first)
        # -----------------------------------------------------
        "match:class ^([Tt]hunar|org.gnome.Nautilus|[Pp]cmanfm-qt|[Dd]olphin)$, tag +file-manager"
        "match:class ^(com.mitchellh.ghostty|org.wezfurlong.wezterm|Alacritty|kitty|kitty-dropterm)$, tag +terminal"
        "match:class ^(Brave-browser(-beta|-dev|-unstable)?)$, tag +browser"
        "match:class ^([Ff]irefox|org.mozilla.firefox|[Ff]irefox-esr)$, tag +browser"
        "match:class ^([Gg]oogle-chrome(-beta|-dev|-unstable)?)$, tag +browser"
        "match:class ^([Tt]horium-browser|[Cc]achy-browser)$, tag +browser"
        "match:class ^(zen-alpha)$, tag +browser"
        "match:class ^(codium|codium-url-handler|VSCodium)$, tag +projects"
        "match:class ^(VSCode|code-url-handler|code)$, tag +projects"
        "match:tag projects*, opacity 1.0 1.0"
        "match:class ^(jetbrains-.*)$, tag +projects"
        "match:class ^(android-studio)$, tag +projects"
        "match:class ^(dbgate)$, tag +projects"
        "match:class ^(httpie)$, tag +projects"
        "match:class ^([Dd]iscord|[Ww]ebCord|[Vv]esktop)$, tag +im"
        "match:class ^([Ff]erdium)$, tag +im"
        "match:class ^([Ww]hatsapp-for-linux)$, tag +im"
        "match:class ^(org.telegram.desktop|io.github.tdesktop_x64.TDesktop)$, tag +im"
        "match:class ^(teams-for-linux)$, tag +im"
        "match:class ^(gamescope)$, tag +games"
        "match:class ^(steam_app_\\d+)$, tag +games"
        "match:class ^([Ss]team)$, tag +gamestore"
        "match:title ^([Ll]utris)$, tag +gamestore"
        "match:class ^(com.heroicgameslauncher.hgl)$, tag +gamestore"
        "match:class ^(com.usebottles.bottles)$, tag +gamestore"
        "match:class ^(gnome-disks|wihotspot(-gui)?)$, tag +settings"
        "match:class ^([Rr]ofi)$, tag +settings"
        "match:class ^(file-roller|org.gnome.FileRoller)$, tag +settings"
        "match:class ^(nm-applet|nm-connection-editor|blueman-manager)$, tag +settings"
        "match:class ^(pavucontrol|org.pulseaudio.pavucontrol|com.saivert.pwvucontrol)$, tag +settings"
        "match:class ^(nwg-look|qt5ct|qt6ct|[Yy]ad)$, tag +settings"
        "match:class (xdg-desktop-portal-gtk), tag +settings"
        "match:class (.blueman-manager-wrapped), tag +settings"
        "match:class (nwg-displays), tag +settings"
        "match:class ^(Mullvad VPN|Cloudflare Zero Trust)$, tag +vpn"
        "match:class ^(swappy)$, tag +image-editor"
        "match:class ^(hyprpolkitagent)$, tag +dialog"

        # Tagging Dialogs & Popups
        "match:title ^(Open File)$, tag +dialog"
        "match:title ^(Select a File)$, tag +dialog"
        "match:title ^(Choose wallpaper)$, tag +dialog"
        "match:title ^(Open Folder)$, tag +dialog"
        "match:title ^(Save As)$, tag +dialog"
        "match:title ^(Library)$, tag +dialog"
        "match:title ^(File Upload)$, tag +dialog"
        "match:class ^(xdg-desktop-portal-gtk)$, tag +dialog"

        # Tagging Steam Extras
        "match:class ^([Ss]team)$, match:title ^(Friends List)$, tag +steam-extras"
        "match:class ^([Ss]team)$, match:title ^(Steam - News)$, tag +steam-extras"
        "match:class ^([Ss]team)$, match:title ^(.* - Chat)$, tag +steam-extras"
        "match:class ^([Ss]team)$, match:title ^(Settings)$, tag +steam-extras"
        "match:class ^([Ss]team)$, match:title ^(.* - Properties)$, tag +steam-extras"
        "match:class ^([Ss]team)$, match:title ^(.* - Event Info)$, tag +steam-extras"
        "match:class ^([Ss]team)$, match:title ^(Small Mode)$, tag +steam-extras"

        # -----------------------------------------------------
        # 2. BEHAVIOR RULES (Apply to tags)
        # -----------------------------------------------------

        # Settings, Dialogs, VPNs: Always float and center
        "match:tag settings*, float on"
        "match:tag settings*, size 70% 70%"
        "match:tag settings*, center on"

        "match:tag dialog*, float on"
        "match:tag dialog*, center on"
        "match:tag dialog*, size 60% 60%"

        "match:tag vpn*, float on"
        "match:tag vpn*, size 300 400"
        "match:tag vpn*, move 75% 5%"
        "match:class ^(Mullvad VPN)$, workspace special"

        # Steam Extras: Float them
        "match:tag steam-extras*, float on"
        "match:tag steam-extras*, center on"

        # Image Editors (Swappy)
        "match:tag image-editor*, float on"
        "match:tag image-editor*, center on"

        # Android Studio & JetBrains Specifics
        "match:class ^(jetbrains-.*)$, match:title ^(Welcome to.*)$, float on"
        "match:class ^(jetbrains-.*)$, match:title ^(Welcome to.*)$, center on"
        "match:class ^(android-studio)$, match:title ^(Welcome to.*)$, float on"
        "match:class ^(android-studio)$, match:title ^(Emulator.*)$, float on"

        # Wine / Fusion360 Splash
        "match:class ^(wine)$, match:title ^(Splash)$, float on"
        "match:class ^(wine)$, match:title ^(Fusion 360)$, float on"

        # Dolphin Dialogs
        "match:class ^(org.kde.dolphin)$, match:title ^(Properties for.*)$, float on"
        "match:class ^(org.kde.dolphin)$, match:title ^(Copying|Moving|Deleting|Progress)$, float on"

        # QBitTorrent
        "match:class ^(org.qbittorrent.qBittorrent)$, tag +downloads"
        "match:class ^(org.qbittorrent.qBittorrent)$, match:title ^(Add Torrent Files)$, float on"
        "match:class ^(org.qbittorrent.qBittorrent)$, match:title ^(Options)$, float on"

        # Moonlight (Treat as Game)
        "match:class ^(moonlight)$, tag +games"

        # EOG (Image Viewer)
        "match:class ^(eog)$, float on"
        "match:class ^(eog)$, center on"

        # Games: High performance mode
        "match:tag games*, no_blur on"
        "match:tag games*, no_shadow on"
        #"match:tag games*, noanim on"
        "match:tag games*, immediate on"
        "match:tag games*, fullscreen on"

        # -----------------------------------------------------
        # 3. SPECIFIC WINDOW FIXES
        # -----------------------------------------------------

        # Picture-in-Picture
        "match:title ^(Picture-in-Picture)$, move 72% 7%"
        "match:title ^(Picture-in-Picture)$, pin on"
        "match:title ^(Picture-in-Picture)$, float on"
        "match:title ^(Picture-in-Picture)$, keep_aspect_ratio on"
        "match:title ^(Picture-in-Picture)$, opacity 0.95 0.75"

        # Steam Menus (Empty titles) - Prevent focus stealing / disappearing
        # "match:class ^([Ss]team)$, match:title ^()$, stayfocused"
        # "match:class ^([Ss]team)$, match:title ^()$, minsize 1 1"

        # LibreOffice
        "match:class ^(libreoffice.*)$, match:title ^(SPLASH)$, float on"
        "match:class ^(libreoffice.*)$, match:title ^(.*Dialog.*)$, float on"
        "match:class ^(libreoffice.*)$, match:title ^(.*Dialog.*)$, center on"

        # Screen Sharing Indicators (Firefox/Chrome/WebRTC)
        "match:title ^(.*Sharing Indicator)$, float on"
        "match:title ^(.*Sharing Indicator)$, move 0 0"
        "match:title ^(.*Sharing Indicator)$, no_focus on"
        #"match:title ^(.*Sharing Indicator)$, noborder on"

        # Dialogs (The "Negative Title" Hack - Keep this!)
        "match:class ([Tt]hunar), match:title negative:.*[Tt]hunar.*, float on"
        "match:class ([Tt]hunar), match:title negative:.*[Tt]hunar.*, center on"
        "match:class ^(com.heroicgameslauncher.hgl)$, match:title negative:Heroic Games Launcher, float on"
        "match:class ^([Ss]team)$, match:title negative:^([Ss]team)$, float on"
        "match:class (codium|codium-url-handler|VSCodium), match:title negative:.*(codium|VSCodium).*, float on"

        # Common Floating Windows
        "match:class ^([Ww]aypaper)$, float on"
        "match:class ^(mpv|com.github.rafostar.Clapper)$, float on"
        "match:title ^(Authentication Required)$, float on"
        "match:title ^(Authentication Required)$, center on"
        "match:initial_title (Add Folder to Workspace), float on"
        "match:initial_title (Open Files), float on"
        "match:initial_title (wants to save), float on"
        "match:initial_title (Open Files), size 70% 60%"
        "match:initial_title (Add Folder to Workspace), size 70% 60%"

        # Ferdium specific overrides
        "match:class ^([Ff]erdium)$, float on"
        "match:class ^([Ff]erdium)$, center on"
        "match:class ^([Ff]erdium)$, size 60% 70%"

        # Global Idle Inhibit
        "match:class .*, idle_inhibit fullscreen"

        # -----------------------------------------------------
        # 4. LOOK & FEEL (Opacity)
        # -----------------------------------------------------
        "match:tag browser*, opacity 1.0 1.0"
        #"match:tag projects*, opacity 0.9 0.8"
        "match:tag im*, opacity 0.94 0.86"
        "match:tag file-manager*, opacity 0.9 0.8"
        "match:tag terminal*, opacity 0.8 0.7"
        "match:tag settings*, opacity 0.8 0.7"
        "match:class ^(gedit|org.gnome.TextEditor|mousepad)$, opacity 0.8 0.7"
        "match:class ^(seahorse)$, opacity 0.9 0.8"
      ];
    };
  };
}
