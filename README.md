# NullOS

A modern, declarative NixOS configuration featuring Hyprland, comprehensive home-manager integration, and per-machine customization.

![NullOS Desktop](_screenshots/desktop.png)
*Main desktop environment with Hyprland and Waybar*

---

## 📖 Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Screenshots](#screenshots)
- [System Components](#system-components)
- [Home Manager Applications](#home-manager-applications)
- [Installation](#installation)
- [Configuration](#configuration)
- [Customization](#customization)
- [Managing Secrets](#managing-secrets)
- [Tips & Tricks](#tips--tricks)

---

## Overview

NullOS is a fully declarative NixOS configuration that provides a polished Wayland desktop experience using Hyprland. It leverages Nix flakes for reproducibility and home-manager for user-level configuration management.

**Key Philosophy:**
- **Declarative Everything** - System and user configurations defined in Nix
- **Per-Machine Flexibility** - Easy multi-host management with shared components
- **Modern Desktop** - Wayland-first with Hyprland compositor
- **Developer-Friendly** - Includes dev tools, containers, and virtualization support

---

## Features

✨ **Desktop Environment**
- Hyprland compositor with custom animations
- Waybar status bar with system monitoring
- Rofi application launcher
- SwayNC notification daemon
- SwayOSD for volume/brightness feedback
- Pyprland scratchpads for quick terminal access
- Hyprlock and Hypridle for screen locking

🎨 **Theming**
- Stylix-based system-wide theming
- GTK and Qt theme coordination
- Automatic wallpaper-based color schemes

🔧 **System Services**
- NVIDIA PRIME support with power-efficient specialisation
- Docker and virtualization ready
- VPN support (Tailscale, Mullvad, Cloudflare WARP, Riseup)
- Sunshine game streaming server
- Ollama AI inference server
- Automated backups with Restic

🛠️ **Development Tools**
- Neovim with Nixvim configuration (also NVF available)
- VSCode with Nix integration
- Android Studio and ADB
- Git with GitHub CLI
- Direnv for project environments

🎮 **Gaming**
- Steam with gamemode
- Lutris game launcher
- Moonlight streaming client
- GameMode performance optimizations
- Fusion 360 (via Wine)

---

## Screenshots

### Desktop Overview
![Desktop Overview](_screenshots/overview.png)

### Rofi Application Launcher
![Rofi Launcher](_screenshots/rofi.png)

### Terminal with Starship Prompt
![Terminal](_screenshots/terminal.png)

### Hyprlock Screen Lock
![Lock Screen](_screenshots/lockscreen.png)

### Waybar Configuration
![Waybar](_screenshots/waybar.png)

---

## System Components

These applications are installed system-wide via NixOS configuration:

### Core System
- **Window Manager**: Hyprland
- **Display Manager**: SDDM
- **Shell**: Zsh with Powerlevel10k
- **Editor**: Neovim (default editor)

### System Utilities
- **File Manager**: Dolphin
- **Terminal**: Ghostty
- **Browser**: Configurable (Brave by default)
- **Audio**: PipeWire + Pavucontrol
- **Brightness Control**: brightnessctl
- **Screenshot**: Custom screenshotin script + Swappy
- **Notifications**: SwayNC
- **OSD**: SwayOSD
- **Display Configuration**: nwg-displays

### Multimedia
- **Video Player**: MPV
- **Music Player**: Rhythmbox
- **Image Viewer**: Eye of GNOME (eog)
- **Screen Streaming**: Gnome Network Displays
- **Game Streaming**: Moonlight, Sunshine

### Gaming
- **Game Launcher**: Lutris
- **CAD/Design**: Fusion 360 (via Wine)

### Productivity
- **Notes**: Obsidian
- **Office Suite**: LibreOffice (Configured via office.nix)
- **Database Client**: DbGate
- **HTTP Client**: HTTPie Desktop
- **Torrent Client**: qBittorrent
- **Communication**: Teams for Linux

### Development
- **Containerization**: Docker, Docker Compose
- **Virtualization**: KVM, libvirt
- **Android**: Android Studio, ADB
- **Version Control**: Git, GitHub CLI (gh)
- **AI/ML**: Ollama

### System Monitoring
- **Process Monitor**: btop, bottom
- **Disk Usage**: gdu, dysk, ncdu
- **System Info**: inxi, lshw, lm_sensors
- **Hardware Utils**: pciutils, usbutils, alsa-utils

### Network & Security
- **VPN**: Tailscale, Mullvad, Cloudflare WARP, OpenFortiVPN, Riseup
- **Secrets**: GnuPG, libsecret, Seahorse
- **Firewall**: Managed by NixOS

### File Tools
- **Archive Support**: p7zip, unrar, unzip
- **Binary Analysis**: binwalk, hexdump
- **File Search**: ripgrep, eza
- **Navigation**: zoxide, yazi

### Media Processing
- **Video/Audio**: ffmpeg, sox
- **Wallpapers**: hyprpaper

---

## Home Manager Applications

User-level applications managed via home-manager:

### Shell & CLI
- **Shell**: Zsh with custom configuration
- **Prompt**: Starship
- **File Explorer**: Yazi
- **Directory Jump**: Zoxide
- **Cat Replacement**: Bat
- **Ls Replacement**: Eza
- **Process Monitor**: Bottom
- **Quick Help**: Tealdeer (tldr)
- **Fetch**: Fastfetch

### Desktop Applications
- **Editor**: VSCode, Neovim (Nixvim/NVF)
- **File Manager**: Dolphin (system integration)
- **HTTP Client**: HTTPie Desktop
- **Office Suite**: LibreOffice (via office.nix)
- **Display Config**: nwg-displays
- **Gaming**: Lutris game launcher
- **CAD**: Fusion 360 (via Wine)

### Wayland Utilities
- **Screenshot**: Custom screenshotin script, Swappy
- **Notifications**: SwayNC
- **OSD**: SwayOSD
- **Wallpaper**: Custom wallsetter script
- **Logout Menu**: wlogout

### Development
- **Git**: Configured with credentials
- **GitHub CLI**: gh
- **Direnv**: Automatic environment loading

### Custom Scripts
Located in `home/scripts/`:
- **screenshotin** - Screenshot utility with area selection
- **keybinds** - List all Hyprland keybindings
- **rofi-launcher** - Custom Rofi launcher wrapper
- **wallsetter** - Wallpaper management and setting

---

## Installation

### Prerequisites

1. A working NixOS installation
2. Git installed
3. Flakes enabled in your Nix configuration

### Enable Flakes

If you haven't enabled flakes, add to `/etc/nixos/configuration.nix`:

```nix
nix.settings.experimental-features = [ "nix-command" "flakes" ];
```

Rebuild: `sudo nixos-rebuild switch`

### Clone Repository

```bash
git clone https://github.com/nullstring1/NullOS.git ~/NullOS
cd ~/NullOS
```

### Configure Variables

1. Copy the example variables file:
```bash
cp variables.nix.example variables.nix
```

2. Edit `variables.nix` with your details:
```nix
{
  username = "youruser";
  hostname = "yourhostname";
  gitUsername = "Your Name";
  gitEmail = "your@email.com";
  # ... customize other settings
}
```

See [Configuration](#configuration) for detailed variable options.

### Add Hardware Configuration

1. Generate hardware config for your machine:
```bash
sudo nixos-generate-config --show-hardware-config > /tmp/hardware.nix
```

2. Create a hardware file in `modules/system/`:
```bash
cp modules/system/hardware_nslapt.nix modules/system/hardware_yourhostname.nix
```

3. Update the hardware file with your configuration from `/tmp/hardware.nix`

### Update Flake

Edit `flake.nix` to add your machine configuration (or modify existing ones):

```nix
nixosConfigurations = {
  yourhostname = nixpkgs.lib.nixosSystem {
    # ... (copy from existing config and adjust)
    modules = [
      # ... other modules
      ./modules/system/hardware_yourhostname.nix
    ];
  };
};
```

### Build and Switch

```bash
sudo nixos-rebuild switch --flake .#yourhostname
```

### First Boot Setup

1. Log out and log back in to apply user environment
2. Set your user password: `passwd`
3. Configure SDDM autologin if desired (see customization)
4. Apply your wallpaper: Run `wallsetter` or place images in `wallpapers/`

---

## Configuration

### Variables File

The `variables.nix` file contains all per-machine customization options:

```nix
{
  # User Configuration
  username = "youruser";          # System username
  hostname = "yourhostname";      # Machine hostname
  gitUsername = "Your Name";      # Git commit name
  gitEmail = "your@email.com";    # Git commit email

  # System Configuration
  system = "x86_64-linux";        # Architecture
  timeZone = "Europe/London";     # Timezone
  locale = "en_GB.UTF-8";         # System locale
  keyboardLayout = "gb";          # X11 keyboard layout
  consoleKeyMap = "uk";           # Console keymap

  # Applications
  terminal = "ghostty";           # Default terminal
  browser = pkgs.brave;           # Default browser

  # NVIDIA Configuration (for laptops with hybrid graphics)
  useNvidiaPrime = true;          # Enable NVIDIA PRIME
  intelBusId = "PCI:0:2:0";       # Intel GPU bus ID
  nvidiaBusId = "PCI:2:0:0";      # NVIDIA GPU bus ID

  # Theming
  stylixImage = wallpapers/screen.jpg;           # Base wallpaper for theming
  waybarConfig = home/waybar/default.nix;        # Waybar configuration
  animationSet = home/hyprland/animations-end4.nix;  # Hyprland animations

  # Backup Configuration
  resticRepository = "sftp:user@host:/backup/path";  # Restic backup target

  # Monitor Configuration
  extraMonitorSettings = ''
    monitor = eDP-1, 1920x1080@60,auto,1
    monitor = HDMI-A-1, 1920x1080@60,1920x0,1
  '';

  # Printing
  printEnable = true;             # Enable printing support
  printDrivers = [ ];             # Additional printer drivers

  # Hardware Additions
  add_rtl8852cu = false;          # Add RTL8852CU WiFi driver
}
```

### Per-Machine Configurations

The flake supports multiple machine configurations:

- **nslapt**: Laptop configuration with NVIDIA PRIME
- **nspc**: Desktop configuration

Each has its own hardware configuration file in `modules/system/`.

### Specialisations

The laptop configuration includes a `power-efficient` specialisation that disables NVIDIA for better battery life:

Boot into it from GRUB or switch with:
```bash
sudo nixos-rebuild switch --flake .#nslapt --specialisation power-efficient
```

---

## Customization

### Changing Themes

NullOS uses Stylix for automatic theming based on wallpapers.

1. Add your wallpaper to `wallpapers/`
2. Update `variables.nix`:
```nix
stylixImage = wallpapers/yourwallpaper.jpg;
```
3. Rebuild: `sudo nixos-rebuild switch --flake .#yourhostname`

### Adding Applications

#### System-Level Applications

Edit `modules/software/packages.nix`:

```nix
environment.systemPackages = with pkgs; [
  # Add your package here
  newpackage
];
```

#### Home-Manager Applications

Create a new file in `home/` or add to existing configuration:

```nix
# home/myapp.nix
{ pkgs, ... }:
{
  home.packages = [ pkgs.myapp ];
}
```

Then import in `home/default.nix`:

```nix
imports = [
  # ... existing imports
  ./myapp.nix
];
```

### Customizing Hyprland

#### Keybindings

Edit `home/hyprland/binds.nix`:

```nix
bind = [
  "SUPER,X,exec,yourcommand"  # Add your keybind
];
```

View current keybinds: Press `SUPER+K` or run `list-keybinds`

#### Animations

Change animation style by updating `variables.nix`:

```nix
animationSet = home/hyprland/animations-end4.nix;  # or create your own
```

#### Window Rules

Edit `home/hyprland/windowrules.nix`:

```nix
windowrule = [
  "match:class (myapp), float on"  # Add custom window rules
];
```

#### Monitor Configuration

Monitor config can be handled by nwg-displays launched with the F8 key by default, or can be set declaratively:

Edit `variables.nix`:

```nix
extraMonitorSettings = ''
  monitor = DP-1, 2560x1440@144, 0x0, 1
  monitor = HDMI-A-1, 1920x1080@60, 2560x0, 1
'';
```

### Customizing Waybar

Edit `home/waybar/default.nix` to modify the status bar layout, modules, and appearance.

### Adding Scratchpads

Edit `home/hyprland/pyprland.nix`:

```nix
[scratchpads.myapp]
animation = "fromTop"
command = "myapplication"
size = "70% 70%"
max_size = "1920px 100%"
```

Bind in `home/hyprland/binds.nix`:

```nix
"SUPER,A,exec,pypr toggle myapp"
```

### Shell Customization

#### Zsh Configuration

Edit `home/zsh/zshrc-personal.nix` for custom shell aliases and functions.

#### Powerlevel10k Prompt

Customize prompt: `home/zsh/p10k-config/p10k.zsh`

Or run the configuration wizard:
```bash
p10k configure
```

### Neovim Configuration

NullOS uses Nixvim as the primary Neovim configuration. Edit `home/nixvim.nix` to customize your editor. An alternative NVF configuration is also available in `home/nvf.nix`.

### Git Configuration

Edit `variables.nix` to set your git identity:

```nix
gitUsername = "Your Name";
gitEmail = "your@email.com";
```

Additional git config can be added in `home/git.nix`.

---

## Managing Secrets

### Per-Machine Files

For files like `variables.nix` that contain sensitive information but must exist for Nix to see them:

**Option 1: Use `--impure` flag (recommended for simplicity)**

```bash
# Add to .gitignore
echo "variables.nix" >> .gitignore
echo "face.jpg" >> .gitignore

# Keep example files tracked
git add variables.nix.example

# Rebuild with --impure flag
sudo nixos-rebuild switch --flake .#yourhostname --impure
```

Create an alias to make it easier:
```bash
alias rebuild='sudo nixos-rebuild switch --flake .#yourhostname --impure'
```

**Option 2: Use agenix for real secrets**

For actual secrets (API keys, passwords), use [agenix](https://github.com/ryantm/agenix):

1. Install agenix and generate keys
2. Create encrypted secret files
3. Reference in your configuration
4. Secrets are decrypted at system activation

See [agenix documentation](https://github.com/ryantm/agenix) for detailed setup.

---

## Tips & Tricks

### Useful Commands

```bash
# Rebuild system (flake reload) 
fr # alias of nh os switch --hostname (hostname)

# Update flake inputs (flake update)
fu # alias of nh os switch --hostname (hostname) --update

# Garbage collection
ncg # alias of nix-collect-garbage --delete-old && sudo nix-collect-garbage -d && sudo /run/current-system/bin/switch-to-configuration boot

# Check flake
nix flake check

# List generations
sudo nix-env --list-generations --profile /nix/var/nix/profiles/system

# Rollback to previous generation
sudo nh os rollback

# Home manager switch (if using standalone)
home-manager switch --flake .
```

### Hyprland Keybinds Quick Reference

Press `SUPER+K` to view all keybindings, or check [home/hyprland/binds.nix](home/hyprland/binds.nix).

**Essential bindings:**
- `SUPER+Return` - Terminal
- `SUPER+SHIFT+Return` - App launcher
- `SUPER+W` - Browser
- `SUPER+E` - File manager
- `SUPER+S` - Screenshot
- `SUPER+C` - VSCode
- `SUPER+T` - Scratchpad terminal
- `SUPER+Q` - Close window
- `SUPER+SHIFT+C` - Exit Hyprland

### NVIDIA Power Management

For laptops with NVIDIA GPUs:

**Boot into power-efficient mode:**
Select "power-efficient" from GRUB menu, or:
```bash
sudo nixos-rebuild boot --flake .#nslapt --specialisation power-efficient
sudo reboot
```

**Check current GPU:**
```bash
glxinfo | grep "OpenGL renderer"
```

### Backup and Restore

The system includes Restic backup configuration. Configure in `variables.nix`:

```nix
resticRepository = "sftp:user@host:/backup/path";
```

Service is defined in `modules/services/backup.nix`.

### Cleaning Up

```bash
# Remove old generations
ncg

nh clean all

# Remove old home-manager generations
home-manager expire-generations "-7 days"
```

### Updating

```bash
# Update all flake inputs
fu
# or 
nix flake update

# Update specific input
nix flake lock --update-input nixpkgs

# Rebuild with updates
sudo nixos-rebuild switch --flake .#yourhostname
# or
fr
# or 
nh os switch --flake .#yourhostname
```

### Troubleshooting

**System won't boot:**
- Select previous generation from GRUB menu
- Or boot from NixOS installer and rollback

**Home manager conflicts:**
- Check `~/.config/` for files that need manual removal
- Home manager backup files have `.backup` extension

**Build errors:**
- Check syntax with `nix flake check`
- Review error messages for missing imports or syntax errors
- Ensure all required files are staged in git (or use `--impure`)

**NVIDIA issues:**
- Check `nvidia-smi` output
- Review NVIDIA module in `modules/system/nvidia.nix`
- Try power-efficient specialisation

---

## Contributing

Feel free to fork this configuration and make it your own! If you find bugs or have improvements, pull requests are welcome.

## License

This configuration is provided as-is for personal use and modification.

---

## Credits

Built with:
- [NixOS](https://nixos.org/)
- [Home Manager](https://github.com/nix-community/home-manager)
- [Hyprland](https://hyprland.org/)
- [Stylix](https://github.com/danth/stylix)
- [NVF](https://github.com/notashelf/nvf)

Original inspiration:
- [Zaneyos](https://gitlab.com/Zaney/zaneyos)

---

**Enjoy your NullOS experience! 🚀**
