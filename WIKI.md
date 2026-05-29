# NullOS Wiki

Welcome to the NullOS documentation wiki! This is a high-level index of topics. For comprehensive information, refer to [README.md](README.md) and [AGENTS.md](AGENTS.md).

## 📚 Quick Navigation

### Getting Started
- Start with [README.md](README.md) - Installation, configuration, and customization
- See [AGENTS.md](AGENTS.md) - Architecture deep-dive, configuration loading pipeline, and advanced topics

### Common Tasks

**Enable/disable features**
→ Edit `machines/{hostname}/default.nix` (e.g., `enableDocker = true`)

**Rebuild system**
→ `nix develop && fr` (or `sudo nixos-rebuild switch --flake .#hostname`)

**Add a system package**
→ Edit `modules/software/packages.nix`

**Change theme/wallpaper**
→ Set `stylixImage` in `machines/{hostname}/default.nix`

**Customize Hyprland**
→ Edit `home/hyprland/binds.nix`, `home/hyprland/windowrules.nix`, etc.

**Configure secrets**
→ Create `machines/{hostname}/secrets.yaml` and encrypt with sops-nix

### Important Concepts

**Configuration Hierarchy**
1. Base defaults → Profile (pc/server) → Machine overrides
2. Result: `vars` object available to all modules
3. See AGENTS.md for details

**Machines Provided**
- **nslapt** - Laptop (NVIDIA Prime, Restic, iOS)
- **nspc** - Desktop (Steam, high-performance)
- **nsminipc** - Headless server (minimal)

**Desktop Environments**
- Hyprland (primary, Lua-based config)
- KDE (secondary, selectable via `desktopEnvironment`)
- Headless (null)

### Key Files

| File | Purpose |
|------|---------|
| `flake.nix` | Entry point, defines system configs and loading pipeline |
| `machines/{hostname}/default.nix` | Per-machine settings and overrides |
| `machines/profiles/base.nix` | Common defaults, feature flags |
| `machines/profiles/{pc,server}.nix` | Profile-specific features |
| `home/default.nix` | Home-manager entry, app configs |
| `modules/` | NixOS system modules |
| `.sops.yaml` + `machines/{hostname}/secrets.yaml` | Encrypted secrets management |

### File Structure

```
NullOS/
├── flake.nix
├── machines/              # Per-machine configs
├── modules/               # System modules (system/, software/, services/)
├── home/                  # Home-manager configs
├── wallpapers/            # Theme images
└── wiki/                  # This documentation
```

See `wiki/file-structure.md` for detailed directory breakdown.

---

## 🔍 Troubleshooting Quick Links

**System won't rebuild?**
- Check syntax: `nix flake check`
- Review error message for missing imports

**Secrets not working?**
- Verify `machines/{hostname}/secrets.yaml` exists and is encrypted
- Check age key at `~/.config/sops/age/keys.txt`
- See Managing Secrets section in README.md

**Home-manager conflicts?**
- Check `~/.config/` for conflicting dotfiles
- Backups have `.backup` extension

**NVIDIA issues?**
- Try power-efficient specialisation: `sudo nixos-rebuild boot --flake .#nslapt --specialisation power-efficient`
- Check `nvidia-smi` output

---

## 📖 Additional Resources

- [NixOS Documentation](https://nixos.org/manual/nixos/stable/)
- [Home Manager Manual](https://nix-community.github.io/home-manager/)
- [Hyprland Wiki](https://wiki.hyprland.org/)
- [Stylix Documentation](https://danth.github.io/stylix/)

---

## 🤝 Contributing

Found an issue or want to improve NullOS? Check [AGENTS.md](AGENTS.md) for architecture details and refer to the main repository for contribution guidelines.
