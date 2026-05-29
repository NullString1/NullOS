# AGENTS.md for NullOS

Declarative NixOS + home-manager configuration with Hyprland support (primary) and KDE (secondary). Multi-machine via flakes.

## Build & Rebuild

NullOS requires `nix develop` first to access build tools. Convenient aliases in `home/zsh/default.nix`:

- `fr` → `nh os switch --hostname ${hostname}` (fast rebuild current machine)
- `fu` → `nh os switch --hostname ${hostname} --update` (rebuild + update flake inputs)
- `ncg` → garbage collection + bootloader cleanup + home-manager generations

Standard rebuild:
```bash
nix develop
sudo nixos-rebuild switch --flake .#hostname
```

**Specialisations** (nslapt only):
- `power-efficient`: Disables NVIDIA GPU, uses modesetting + Intel PSR/FBC for battery life
```bash
sudo nixos-rebuild boot --flake .#nslapt --specialisation power-efficient
sudo reboot
```

## Architecture

**Configuration Loading Pipeline** (flake.nix lines 58-100):
1. Load base defaults from `machines/profiles/base.nix` (~70 feature flags, most false)
2. Merge profile config from `machines/profiles/{base.profile}.nix` (pc or server)
3. Apply machine overrides from `machines/{hostname}/default.nix`
4. Result: `vars` object passed to all modules via `specialArgs`

**Machines:**
- `nslapt`: Laptop, profile=pc, NVIDIA Prime (Intel iGPU + NVIDIA dGPU), passwordless sudo
- `nspc`: Desktop, profile=pc, full NVIDIA (open driver), Steam enabled
- `nsminipc`: Headless server, profile=server, `desktopEnvironment = null`, minimal services

**Profiles** (`machines/profiles/`):
- `base.nix`: Common defaults (keyboard, locale, git, browser, all feature flags disabled)
- `pc.nix`: Enable 20+ features (Docker, VSCode, Android, Wine, Tailscale, Flatpak, etc.)
- `server.nix`: Minimal (Docker, Git, Direnv, Tailscale only)

**Module Structure:**
- `modules/system/` → NixOS core (boot, hardware, network, nvidia, audio, security, printing, system)
- `modules/software/` → Packages, programs, SDDM display manager, conditional features
- `modules/services/` → Systemd services (ollama, backup, minecraft, nextdns, vpn, etc.)
- `home/` → Home-manager config (97 files); DE-agnostic + DE-specific branches

**Flake Outputs:**
- `nixosConfigurations.{hostname}` → Full system (hardware + home-manager embedded)
- `homeConfigurations.username@hostname` → Standalone home-manager (3 instances: nullstring1@nslapt/nspc/nsminipc)
- `formatter.x86_64-linux` → nixfmt

## Key Design Quirks

**Machine Config Polymorphism**: Machine configs in `machines/{hostname}/default.nix` can define variables inline (legacy style) OR nested in `.vars` object (modern style). Flake auto-detects and merges both. Any attribute not matching reserved keywords or known defaults becomes `extraNixosConfig`, allowing machine configs to define arbitrary NixOS settings.

**Type Inference Example** (nsminipc):
```nix
desktopEnvironment = null;  # Vars attribute (disables SDDM, X server, desktop modules)
boot.devSize = "8G";        # Auto-inferred as NixOS config (not vars)
services.periodic-reboot = {...};  # Auto-inferred as NixOS config
```

**Hyprland Config is Lua-Based**: Modern config uses `configType = "lua"` with Nix generating Lua. Monitor setup dynamically loaded via `require("monitors")` from `vars.extraMonitorSettings`.

**Desktop Environment Polymorphism**: Single config tree supports Hyprland (primary) and KDE via `vars.desktopEnvironment` ("hyprland", "kde", or null). Home-manager conditionally imports DE-specific modules.

**Catppuccin Theme Selective Enable**: Theme config has `enable = false` for hyprland/hyprlock (custom theme?) but true for swaync/wlogout/starship. Non-standard pattern; suggests incomplete migration or intentional override.

**Distributed Builds**: nspc statically configured as build machine for all hosts via SSH (speedFactor 2x). Requires pre-configured SSH keys.

**Architecture-Specific Caching**: nslapt includes gccarch-tigerlake system feature (Intel 11th gen); nspc uses gccarch-x86-64-v3. Enables targeted binary caching.

**NextDNS Under Refactor** (staged changes): Old approach uses direct `lib.readFile` from sops secrets; new uses sops template generation + dnscrypt-proxy. Existing NextDNS setups will break on rebuild with staged changes.

## Secrets & Per-Machine Overrides

Per-machine config lives in `machines/{hostname}/default.nix` (no separate variables.nix). Feature flags and settings can be overridden there.

**Real secrets** (API keys, tokens): Use `machines/{hostname}/secrets.yaml` with sops-nix:
- Encrypted with age key at `~/.config/sops/age/keys.txt`
- Expected secrets: `githubToken`, and conditional (`nextdnsServerName`, `nextdnsStamp`, `nextdnsIpUpdateUrl` if NextDNS enabled; `resticRepository` if Restic backup enabled)
- Rules in `.sops.yaml` match `machines/.*/secrets.yaml`

**.envrc Git Filter** (if variables.nix existed): `.envrc` has git config to mask `variables.nix` from diffs. Currently unused but framework in place.

## Important Files

- `flake.nix` → Defines machines, profiles, overlays, loadMachineConfig logic
- `machines/{hostname}/default.nix` → Per-machine vars + NixOS config overrides
- `machines/profiles/base.nix` → Default feature flags and system defaults
- `modules/system/` → Hardware, boot, network, NVIDIA, audio, security, printing, system.nix
- `modules/software/packages.nix` → Base system packages; feature gating via `enable*` vars
- `modules/software/sddm.nix` → Display manager (conditional on desktopEnvironment != null)
- `modules/services/services.nix` → Always-on systemd services
- `home/default.nix` → Home-manager module imports (conditional on vars.desktopEnvironment)
- `home/hyprland/` → Hyprland config (Lua-based, binds.nix, animations, pyprland scratchpads, windowrules.nix)
- `home/waybar/default.nix` → Status bar layout and modules
- `home/zsh/` → Shell config, aliases, Powerlevel10k prompt
- `home/nixvim.nix` → Neovim config (Nixvim, if enableNVIM=true)

## Common Tasks

**Enable/disable feature for machine**: Edit `machines/{hostname}/default.nix`, add `enableX = true/false`

**Add system package**: Edit `modules/software/packages.nix` (environment.systemPackages)

**Add home-manager module**: Create `home/myapp.nix`, import in `home/default.nix` (conditionally if feature-gated)

**Change wallpaper/theme**: Update `stylixImage` in machine config, rebuild

**Add Hyprland keybinding**: Edit `home/hyprland/binds.nix`

**Customize shell**: Edit `home/zsh/default.nix` (shellAliases) or `home/zsh/zshrc-personal.nix` (custom functions)

**Monitor config**: Runtime via `nwg-displays` (F8 key), or declarative via `extraMonitorSettings` in machine config

**Add service**: Create `modules/services/myservice.nix`, conditionally import in `modules/services/default.nix`

## Entering Dev Shell

```bash
nix develop
# or with direnv (auto):
direnv allow
```

Provides nixfmt (formatter) and build tools.

## Testing & Debugging

Check flake syntax:
```bash
nix flake check
```

Dry-run (shows what would rebuild):
```bash
sudo nixos-rebuild build --flake .#hostname
```

Evaluate home-manager output:
```bash
nix eval .#homeConfigurations.username@hostname
```

View current generation:
```bash
sudo nix-env --list-generations --profile /nix/var/nix/profiles/system
```

Rollback to previous generation:
```bash
sudo nh os rollback
```
