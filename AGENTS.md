# AGENTS.md for NullOS

Declarative NixOS + home-manager configuration with Hyprland (primary) and KDE (secondary) desktop support, or headless. Multi-machine via flakes.

## Quick Reference

**Rebuild** (requires `nix develop` first):
```bash
nix develop
fr   # rebuild current machine (alias for: nh os switch --hostname ${hostname})
fu   # rebuild + update inputs (alias for: nh os switch --hostname ${hostname} --update)
ncg  # garbage collection + bootloader cleanup
```

**Specialisations** (nslapt only):
```bash
sudo nixos-rebuild boot --flake .#nslapt --specialisation power-efficient
sudo reboot  # disables NVIDIA for battery life
```

## Configuration Loading (Critical)

Three-stage pipeline (flake.nix:58-100):
1. **Base** (`machines/profiles/base.nix`) - ~70 feature flags, most false
2. **Profile** (`machines/profiles/{pc,server}.nix`) - Feature sets based on machine class
3. **Machine** (`machines/{hostname}/default.nix`) - Per-machine overrides

Result: `vars` object available to all modules via `specialArgs`. Machines define configs inline OR nested in `.vars` object (flake auto-detects and merges).

**Key quirk**: Non-reserved attributes in machine config become `extraNixosConfig`, allowing arbitrary NixOS config in machine file (e.g., `boot.devSize`, `services.periodic-reboot` in nsminipc).

## Machines

- **nslapt** (pc) - NVIDIA Prime (Intel iGPU + dGPU), passwordless sudo, Restic, iOS support (usbmuxd)
- **nspc** (pc) - Full NVIDIA (open driver), Steam enabled
- **nsminipc** (server) - Headless (`desktopEnvironment = null`), minimal services

## Architecture Notes

**Desktop polymorphism**: `vars.desktopEnvironment` selects "hyprland", "kde", or null. Single config tree supports all; home-manager conditionally imports DE modules.

**Hyprland Lua config**: Uses `configType = "lua"`; monitor setup dynamically loaded via `require("monitors")` from `vars.extraMonitorSettings`.

**Secrets with sops-nix**: `machines/{hostname}/secrets.yaml` encrypted with age key at `~/.config/sops/age/keys.txt`. Expected: `githubToken`, plus conditionals (`nextdnsServerName`, `nextdnsStamp`, `nextdnsIpUpdateUrl` if NextDNS enabled; `resticRepository` if Restic enabled).

**Distributed builds**: nspc configured as SSH build machine (speedFactor 2x) for all hosts. Requires pre-configured SSH keys.

**Architecture-specific caching**: nslapt has `gccarch-tigerlake` (Intel 11th gen); nspc has `gccarch-x86-64-v3`. Enables targeted binary cache.

**Catppuccin theme quirk**: Theme `enable = false` for hyprland/hyprlock but true for swaync/wlogout/starship. Suggests custom theme or incomplete migration.

## Important File Locations

| File | Purpose |
|------|---------|
| `flake.nix` | Machine definitions, profile loading, overlays |
| `machines/{hostname}/default.nix` | Per-machine vars + NixOS overrides |
| `machines/profiles/base.nix` | Feature flags, system defaults |
| `modules/system/` | Boot, hardware, network, NVIDIA, audio, security, printing |
| `modules/software/packages.nix` | System packages, feature gating |
| `home/default.nix` | Home-manager conditional imports |
| `home/hyprland/binds.nix` | Hyprland keybindings |
| `home/zsh/default.nix` | Shell aliases (`fr`, `fu`, `ncg` defined here) |

## Common Edits

- **Feature toggle** (per machine): Edit `machines/{hostname}/default.nix`, add `enableX = true/false`
- **System package**: Edit `modules/software/packages.nix` (environment.systemPackages)
- **Home-manager app**: Create `home/myapp.nix`, import in `home/default.nix` (conditionally if feature-gated)
- **Keybinding**: Edit `home/hyprland/binds.nix`
- **Theme/wallpaper**: Update `stylixImage` in machine config
- **Shell aliases**: Edit `home/zsh/default.nix` (shellAliases) or `home/zsh/zshrc-personal.nix`
- **Monitor config**: Declarative via `extraMonitorSettings` in machine config, or runtime via `nwg-displays` (F8 key)
- **Service**: Create `modules/services/myservice.nix`, conditionally import in `modules/services/default.nix`

## Debugging Commands

```bash
nix flake check                                              # Validate flake syntax
sudo nixos-rebuild build --flake .#hostname                 # Dry-run (no reboot)
nix eval .#homeConfigurations.username@hostname             # Inspect home-manager output
sudo nix-env --list-generations --profile /nix/var/nix/profiles/system
sudo nh os rollback                                          # Rollback to previous generation
```

## Known Issues

**NextDNS refactoring** (staged changes): Old approach uses direct `lib.readFile` from sops secrets; new uses sops template generation + dnscrypt-proxy. Existing NextDNS setups will break on rebuild with staged changes.
