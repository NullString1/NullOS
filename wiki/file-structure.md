# File Structure

Understanding the NullOS directory structure will help you navigate and customize your configuration effectively.

## 📁 Root Directory

```
NullOS/
├── flake.nix              # Main flake configuration
├── flake.lock            # Locked flake dependencies
├── variables.nix         # Per-machine variables (gitignored)
├── variables.nix.example # Template for variables
├── .gitignore           # Git ignore rules
├── .gitattributes       # Git attributes
├── .envrc               # Direnv configuration
├── README.md            # Main documentation
├── WIKI.md              # Wiki index
├── _screenshots/        # Screenshots directory
├── wallpapers/          # Wallpaper images
├── home/               # Home Manager configurations
├── modules/            # NixOS system modules
└── wiki/               # Documentation wiki
```

## 🏠 Home Directory (`home/`)

User-level configurations managed by Home Manager:

```
home/
├── default.nix          # Main home-manager entry point
├── bat.nix             # Bat (cat alternative) config
├── bottles.nix         # Bottles (Wine manager)
├── bottom.nix          # Bottom (process monitor)
├── eza.nix            # Eza (ls alternative)
├── gh.nix             # GitHub CLI
├── ghostty.nix        # Ghostty terminal
├── git.nix            # Git configuration
├── gtk.nix            # GTK theming
├── httpie-desktop.nix # HTTPie desktop client
├── kde.nix            # KDE integration
├── nvf.nix            # Neovim (NVF) config
├── nwg-displays.nix   # Display configuration tool
├── office.nix         # Office suite
├── qt.nix             # Qt theming
├── starship.nix       # Starship prompt
├── stylix.nix         # Stylix theming
├── swappy.nix         # Screenshot annotation
├── swaync.nix         # Notification daemon
├── swayosd.nix        # On-screen display
├── tealdeer.nix       # tldr client
├── vscode.nix         # VSCode configuration
├── xdg.nix            # XDG directory setup
├── zoxide.nix         # Directory jumper
├── fastfetch/         # Fastfetch config
│   └── default.nix
├── hyprland/          # Hyprland compositor config
│   ├── default.nix
│   ├── animations-end4.nix
│   ├── binds.nix
│   ├── env.nix
│   ├── hypridle.nix
│   ├── hyprland.nix
│   ├── hyprlock.nix
│   ├── pyprland.nix
│   └── windowrules.nix
├── rofi/              # Rofi launcher config
│   ├── default.nix
│   ├── config-long.nix
│   └── rofi.nix
├── scripts/           # Custom scripts
│   ├── keybinds.nix
│   ├── rofi-launcher.nix
│   ├── screenshotin.nix
│   └── wallsetter.nix
├── waybar/            # Waybar status bar
│   └── default.nix
├── wlogout/           # Logout menu
│   ├── default.nix
│   └── icons/
├── yazi/              # Yazi file manager
│   ├── default.nix
│   ├── keymap.nix
│   ├── theme.nix
│   └── yazi.nix
└── zsh/               # Zsh shell config
    ├── default.nix
    ├── zshrc-personal.nix
    └── p10k-config/
        └── p10k.zsh
```

## ⚙️ Modules Directory (`modules/`)

System-level NixOS modules:

```
modules/
├── misc/              # Miscellaneous configurations
│   ├── default.nix
│   ├── fonts.nix      # System fonts
│   └── user.nix       # User configuration
├── services/          # System services
│   ├── default.nix
│   ├── backup.nix     # Restic backup
│   ├── ollama.nix     # Ollama AI server
│   ├── services.nix   # Core services
│   ├── sunshine.nix   # Game streaming
│   ├── virtualisation.nix  # Docker/libvirt
│   ├── vpn.nix        # VPN services
│   └── xserver.nix    # X server config
├── software/          # Software packages
│   ├── default.nix
│   ├── android-studio.nix
│   ├── dolphin.nix    # File manager
│   ├── flatpak.nix    # Flatpak support
│   ├── nh.nix         # Nix helper
│   ├── packages.nix   # System packages
│   ├── sddm.nix       # Display manager
│   ├── starship.nix   # Starship system config
│   └── steam.nix      # Steam gaming
└── system/            # System configuration
    ├── default.nix
    ├── audio.nix      # Audio (PipeWire)
    ├── boot.nix       # Boot configuration
    ├── hardware_add.nix    # Additional hardware
    ├── hardware_nslapt.nix # Laptop hardware
    ├── hardware_nspc.nix   # Desktop hardware
    ├── network.nix    # Network configuration
    ├── nvidia.nix     # NVIDIA drivers
    ├── power.nix      # Power management
    ├── printing.nix   # Printing support
    ├── rtl8852cu.nix  # WiFi driver
    ├── security.nix   # Security settings
    └── system.nix     # Core system config
```

## 🔧 Configuration Flow

### System-Level Flow

1. **flake.nix** - Entry point that defines:
   - Flake inputs (nixpkgs, home-manager, etc.)
   - System configurations (nslapt, nspc)
   - User configuration via home-manager integration

2. **variables.nix** - Imported by flake.nix:
   - Contains per-machine settings
   - User preferences
   - Hardware-specific options

3. **modules/** - Imported by system configuration:
   - System-level packages and services
   - Hardware configuration
   - Service enablement

### User-Level Flow

1. **home/default.nix** - Home Manager entry point:
   - Imports all user-level modules
   - Defines custom scripts

2. **home/*/**.nix** - Individual application configs:
   - Application-specific settings
   - User packages
   - Dotfile configurations

## 📝 Key Files

### Essential Configuration Files

- **flake.nix** - The heart of NullOS. Defines:
  - System configurations
  - Home-manager integration
  - Flake inputs and outputs
  - User and system module imports

- **variables.nix** - Per-machine customization:
  - Username, hostname, locale
  - Git credentials
  - Application preferences
  - Hardware settings (NVIDIA, monitors)
  - Theming choices

### Hardware Configuration

- **modules/system/hardware_*.nix** - Machine-specific:
  - Filesystem configuration
  - Kernel modules
  - Boot settings
  - Hardware quirks

### Theming Files

- **home/stylix.nix** - System-wide theming
- **home/gtk.nix** - GTK theme overrides
- **home/qt.nix** - Qt theme configuration
- **wallpapers/** - Wallpaper images for Stylix

### Application Configurations

Each application has its own Nix file:
- Declarative configuration
- Package installation
- Service enablement
- Dotfile management

## 🎯 Where to Make Changes

### Adding System Packages
→ `modules/software/packages.nix`

### Adding User Packages
→ Create new file in `home/` or add to existing one

### Changing Keybindings
→ `home/hyprland/binds.nix`

### Modifying Waybar
→ `home/waybar/default.nix`

### Customizing Shell
→ `home/zsh/zshrc-personal.nix`

### Theming Changes
→ `variables.nix` (change stylixImage)
→ `home/stylix.nix` (override specific theme elements)

### System Services
→ `modules/services/*.nix`

### Hardware Settings
→ `modules/system/hardware_yourhostname.nix`
→ `variables.nix` (monitor config, NVIDIA settings)

## 🔄 Import Chain

Understanding how files are imported:

```
flake.nix
├── variables.nix (imported as vars)
└── nixosConfigurations.yourhostname
    ├── modules/misc/default.nix
    │   ├── fonts.nix
    │   └── user.nix
    ├── modules/services/default.nix
    │   ├── backup.nix
    │   ├── services.nix
    │   └── ...
    ├── modules/software/default.nix
    │   ├── packages.nix
    │   └── ...
    ├── modules/system/default.nix
    │   ├── audio.nix
    │   ├── boot.nix
    │   └── ...
    ├── modules/system/hardware_yourhostname.nix
    └── home-manager.users.yourusername
        └── home/default.nix
            ├── hyprland/default.nix
            │   ├── binds.nix
            │   ├── hyprland.nix
            │   └── ...
            ├── scripts/*.nix
            ├── waybar/default.nix
            └── ...
```

## 💡 Tips

### Adding New Modules

1. Create your module file in appropriate directory:
   - System-level: `modules/*/yourmodule.nix`
   - User-level: `home/yourmodule.nix`

2. Import in parent `default.nix`:
   ```nix
   imports = [
     ./yourmodule.nix
   ];
   ```

3. Rebuild to apply changes

### Organizing Custom Configurations

- Keep related configs together in subdirectories
- Use `default.nix` as the entry point for multi-file configs
- Import all files from `default.nix`

### Using Variables

Access variables in any module:
```nix
{ vars, ... }:
{
  # Use vars.username, vars.terminal, etc.
}
```

Variables are available because they're passed via `specialArgs` in flake.nix.
