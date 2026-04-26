# OmniLinux Agents Knowledge Base
# Instructions and conventions for maintaining OmniLinux

## Project Overview

OmniLinux is a modern, all-in-one Linux distribution featuring:
- 3 Desktop Environments: GNOME, KDE Plasma, XFCE
- Pre-installed Dev, Security, and Gaming stacks
- Built on Ubuntu 24.04 (Noble) base
- Uses live-build system for ISO creation

## Build Commands

```bash
# Standard build (from Ubuntu/Debian)
cd OmniLinux
sudo ./build.sh

# Individual live-build commands
sudo lb config        # Configure build
sudo lb bootstrap     # Download base system
sudo lb chroot        # Install packages
sudo lb build         # Create ISO
sudo lb clean --all   # Clean build artifacts
```

## Key File Locations

| Purpose | Location |
|---------|----------|
| Package lists | `config/package-lists/*.list.chroot` |
| Build hooks | `config/hooks/live/*.hook.chroot` |
| System files | `config/includes.chroot/` |
| Boot files | `config/includes.binary/` |
| Branding | `branding/` |
| Scripts | `scripts/` |
| Live-build auto | `auto/` |

## Package List Conventions

Package lists are processed in alphabetical order:
- `01-base.list.chroot` - Core packages
- `02-gnome.list.chroot` - GNOME packages
- `03-kde.list.chroot` - KDE packages
- `04-xfce.list.chroot` - XFCE packages
- `05-productivity.list.chroot` - Office/media
- `06-development.list.chroot` - Dev tools
- `07-security.list.chroot` - Security tools
- `08-gaming.list.chroot` - Gaming packages
- `09-installer.list.chroot` - Calamares
- `10-live-boot.list.chroot` - Live boot tools
- `11-boot-theme.list.chroot` - Plymouth themes
- `12-fonts.list.chroot` - Fonts

## Hook Script Conventions

Hooks run in alphabetical order during chroot phase:

| Hook | Purpose |
|------|---------|
| `00-policy-rc.hook.chroot` | Disable service autostart |
| `00-locale.hook.chroot` | Set locale |
| `00-keyboard.hook.chroot` | Configure keyboard |
| `01-system-config.hook.chroot` | UFW, AppArmor setup |
| `02-theming.hook.chroot` | Theme configuration |
| `03-zsh-setup.hook.chroot` | ZSH shell setup |
| `04-flatpak-setup.hook.chroot` | Flatpak configuration |
| `05-performance.hook.chroot` | System optimizations |
| `06-branding.hook.chroot` | OS release info |
| `07-packages.hook.chroot` | Additional packages |
| `08-finalize.hook.chroot` | Cleanup |

## Branding Colors

| Name | Hex | Usage |
|------|-----|-------|
| OmniBlue | #3D7EFF | Primary accent |
| OmniDark | #0D1117 | Dark backgrounds |
| OmniLight | #F0F4FF | Light text |
| OmniPurple | #7C3AED | Secondary accent |
| OmniGreen | #10B981 | Success states |

## Common Tasks

### Adding a New Desktop Environment
1. Create package list in `config/package-lists/`
2. Add DE packages (display manager, session, apps)
3. Create session selector entry in hooks
4. Update branding if needed

### Adding a New Package Category
1. Create package list file
2. Name starting with number for order
3. Add to appropriate section
4. Test build

### Modifying Boot Experience
1. Edit `config/includes.binary/isolinux/` for BIOS boot
2. Edit `config/includes.chroot/etc/default/grub.d/` for GRUB
3. Modify `branding/plymouth-theme/` for splash screen

## Testing Checklist

Before release:
- [ ] ISO builds without errors
- [ ] Live boot works (VM test)
- [ ] All 3 DEs launch
- [ ] Network connectivity works
- [ ] Package installation works
- [ ] Installer launches
- [ ] Filesystem integrity

## Known Issues

- Custom kernel not included (uses generic HWE)
- Steam requires multiverse repository
- Some gaming tools need post-install setup

## Development Workflow

```bash
# 1. Make changes
# 2. Clean previous build
sudo lb clean --all

# 3. Rebuild
sudo ./build.sh

# 4. Test in VM
qemu-system-x86_64 -m 4G -cdrom OmniLinux-*.iso

# 5. Debug if needed
# Check logs in config/ or auto/
```

## Configuration Files

### live-build auto/config
Sets build parameters (distribution, mirrors, ISO settings)

### auto/bootstrap
Controls base system bootstrap

### auto/binary
Controls ISO creation parameters

### auto/chroot
Controls package installation phase

## Contributing

1. Test changes locally
2. Ensure ISO builds successfully
3. Update documentation
4. Submit changes with clear commit messages