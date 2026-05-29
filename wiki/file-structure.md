# File Structure

Understanding the NullOS directory structure will help you navigate and customize your configuration effectively.

## 📁 Root Directory

```
NullOS/
├── flake.nix              # Main flake configuration
├── flake.lock            # Locked flake dependencies
├── .gitignore           # Git ignore rules
├── .gitattributes       # Git attributes
├── .envrc               # Direnv configuration
├── .sops.yaml           # sops-nix encryption rules
├── README.md            # Main documentation
├── WIKI.md              # Wiki index
├── AGENTS.md            # Agent/automation documentation
├── _screenshots/        # Screenshots directory
├── wallpapers/          # Wallpaper images
├── machines/            # Per-machine configurations
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
├── fusion360.nix      # Fusion 360 (CAD via Wine)
├── gh.nix             # GitHub CLI
├── ghostty.nix        # Ghostty terminal
├── git.nix            # Git configuration
├── gtk.nix            # GTK theming
├── httpie-desktop.nix # HTTPie desktop client
├── kde.nix            # KDE integration
├── lutris.nix         # Lutris game launcher
├── nixvim.nix         # Neovim (Nixvim) config
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

## ⚙️ Machines Directory (`machines/`)

Per-machine NixOS configurations:

```
machines/
├── profiles/
│   ├── base.nix          # Default feature flags and common settings
│   ├── pc.nix            # PC profile (20+ features enabled)
│   └── server.nix        # Server profile (minimal, headless)
├── nslapt/
│   ├── default.nix       # Laptop machine config (NVIDIA Prime, etc.)
│   └── secrets.yaml      # Encrypted secrets (sops-nix)
├── nspc/
│   ├── default.nix       # Desktop machine config (Steam, etc.)
│   └── secrets.yaml      # Encrypted secrets
└── nsminipc/
    ├── default.nix       # Server machine config (headless)
    └── secrets.yaml      # Encrypted secrets
```

**Understanding per-machine configs:**

Each `machines/{hostname}/default.nix` defines:
- User settings (username, git email, timezone)
- Desktop environment choice (hyprland, kde, or null)
- Hardware config (GPU, monitor settings)
- Feature toggles (Docker, VSCode, Android, Steam, etc.)
- Service config (Restic backup target, VPN, etc.)
- Theming overrides (wallpaper image, Stylix settings)

Example structure in `machines/nslapt/default.nix`:
```nix
{
  # Loaded into vars, merged with base → pc profile
  username = "nullstring1";
  gitUsername = "Null String";
  gitEmail = "user@example.com";
  
  timeZone = "Europe/London";
  locale = "en_GB.UTF-8";
  desktopEnvironment = "hyprland";
  
  useNvidiaPrime = true;
  intelBusId = "PCI:0:2:0";
  nvidiaBusId = "PCI:2:0:0";
}
```

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

### Three-Stage Configuration Loading

1. **Base Defaults** (`machines/profiles/base.nix`)
   - Common system settings (keyboard, locale, git)
   - ~70 feature flags, mostly disabled
   - Applies to all machines

2. **Profile Configuration** (`machines/profiles/{pc,server}.nix`)
   - Merges with base defaults
   - `pc.nix`: Enables 20+ features (Docker, VSCode, Android, Wine, Steam, Tailscale, etc.)
   - `server.nix`: Minimal (Docker, Git, Direnv, Tailscale only)

3. **Machine Overrides** (`machines/{hostname}/default.nix`)
   - Final per-machine customization
   - Overrides anything from base or profile
   - Results in `vars` object passed to all modules via `specialArgs`

**Example:** Setting up nslapt laptop
```
base.nix (common defaults)
    ↓
pc.nix (enables Docker, VSCode, Steam, etc.)
    ↓
machines/nslapt/default.nix (laptop-specific: NVIDIA Prime, Restic, iOS support)
    ↓
vars object available to all modules
```

### System-Level Configuration Flow

1. **flake.nix** - Entry point:
   - Defines flake inputs (nixpkgs, home-manager, etc.)
   - Loads machine config: base → profile → machine overrides
   - Creates `vars` object via `specialArgs`
   - Defines `nixosConfigurations.{hostname}`

2. **machines/{hostname}/default.nix** - Machine config:
   - Per-machine settings merged into `vars`
   - Settings available to all modules

3. **modules/** - System modules:
   - Access settings via `vars` parameter
   - System-level packages, services, hardware config
   - Organized as: system/ (boot, hardware, NVIDIA), software/ (packages, SDDM), services/

4. **home/default.nix** - Home-manager entry:
   - User-level configuration
   - Desktop environment conditional (Hyprland/KDE/null)
   - Imports application-specific modules

### User-Level Configuration Flow

1. **home/default.nix** - Home Manager entry point:
   - Conditionally imports modules based on desktop environment
   - Defines custom scripts and utilities

2. **home/*/**.nix** - Individual application configs:
   - Application-specific settings
   - User packages
   - Dotfile configurations (git, zsh, neovim, etc.)

## 📝 Key Files

### Essential Configuration Files

- **flake.nix** - The heart of NullOS. Defines:
  - System configurations
  - Home-manager integration
  - Three-stage loading: base → profile → machine overrides
  - User and system module imports via `specialArgs`

- **machines/{hostname}/default.nix** - Per-machine customization:
  - Username, hostname, locale, timezone
  - Git credentials
  - Application preferences
  - Hardware settings (NVIDIA, monitors)
  - Desktop environment selection
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

### Enable/Disable Features for a Machine
→ Edit `machines/{hostname}/default.nix`

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
→ `machines/{hostname}/default.nix` (set `stylixImage`)
→ `home/stylix.nix` (override specific theme elements)

### System Services
→ `modules/services/*.nix`

### Hardware Settings
→ `modules/system/hardware_yourhostname.nix`
→ `machines/{hostname}/default.nix` (GPU, monitor config)

## 🔄 Import Chain

Understanding how files are imported and merged:

```
flake.nix (entry point)
├── machines/profiles/base.nix (stage 1: common defaults)
│   └── machines/profiles/{pc,server}.nix (stage 2: profile features)
│       └── machines/{hostname}/default.nix (stage 3: machine overrides)
│           └── vars object created and passed to all modules
│
└── nixosConfigurations.{hostname}
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
    ├── modules/system/hardware_{hostname}.nix
    └── home-manager.users.{username}
        └── home/default.nix (conditional on desktopEnvironment)
            ├── home/hyprland/default.nix (if Hyprland)
            │   ├── binds.nix
            │   ├── hyprland.nix
            │   └── ...
            ├── home/kde.nix (if KDE)
            ├── home/scripts/*.nix
            ├── home/waybar/default.nix
            └── ...
```

**Key:** The three-stage merge (base → profile → machine) creates `vars`, which is then passed to all modules via `specialArgs`, making settings available everywhere.

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
