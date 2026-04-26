# OmniLinux Package Reference

This document outlines the high-level packages that form the various layers of OmniLinux.

## Base System
- Kernel: `linux-image-generic` (Target: patched Zen kernel depending on availability).
- Init: `systemd`
- Core: `ubuntu-desktop-minimal`, `network-manager`, `pipewire`

## Desktop Environments (Sessions)
1. **GNOME (Default):** `ubuntu-desktop-minimal`, `gnome-shell`, `nautilus`, `gnome-console`, GNOME extensions.
2. **KDE Plasma (Gaming/Power):** `kde-plasma-desktop`, `dolphin`, `konsole`.
3. **XFCE (Lightweight):** `xfce4`, `thunar`, `picom`, `xfce4-terminal`.

## Productivity Software
- `libreoffice`, `thunderbird`, `vlc`, `gimp`, `inkscape`, `keepassxc`.

## Development Software
- `git`, `docker.io`, `docker-compose`, `python3`, `nodejs`, `npm`, `zsh`.
- IDEs (e.g., VS Code) are installed via Flatpak or separate APT repositories during hooks.

## Gaming Stack (KDE Focused)
- `steam`, `lutris`, `gamemode`, `mangohud`, `wine64`.

## Security Tools
- Standard utilities: `nmap`, `netcat`, `wireshark`.
- Specialized tools are available via an opt-in installation script `omni-install.sh`.
