# OmniLinux Build Instructions

Complete guide to building OmniLinux ISO from source.

## Requirements

### Hardware
- **CPU**: 64-bit x86_64
- **RAM**: 8GB minimum (12GB recommended)
- **Disk**: 50GB free space
- **Network**: Stable internet connection (downloads ~4GB)

### Software
- **OS**: Ubuntu 22.04+ or Debian 12+ (WSL2 also works)
- **Root**: sudo access required

## Quick Start

```bash
# 1. Install dependencies
sudo apt update
sudo apt install -y live-build debootstrap squashfs-tools xorriso \
    grub-efi-amd64 mtools git curl wget isolinux syslinux-common \
    parted gdisk locales

# 2. Clone/build
cd OmniLinux
sudo ./build.sh

# 3. Wait 1-2 hours for build to complete
# Output: OmniLinux-1.0-LTS-amd64.iso
```

## Build Process Explained

### Step 1: Dependency Check
The build script verifies all required tools are installed.

### Step 2: Live-Build Configuration
Creates live-build configuration files in `./config/`:
- Package lists define what gets installed
- Hooks define custom configuration scripts
- Includes define files to copy into the image

### Step 3: Bootstrap
Downloads and extracts Ubuntu base system (~500MB).

### Step 4: Package Installation
Installs all packages from package lists (~2-3GB).

### Step 5: ISO Build
Creates bootable ISO with squashfs and bootloader.

## Customization

### Adding Packages
Edit files in `config/package-lists/`:
- `01-base.list.chroot` - Core system packages
- `02-gnome.list.chroot` - GNOME desktop
- `03-kde.list.chroot` - KDE Plasma desktop
- `04-xfce.list.chroot` - XFCE desktop
- Add new lists as needed

### Adding Hooks
Add scripts to `config/hooks/live/`:
- Scripts run in order (00-*, 01-*, etc.)
- Execute during chroot phase
- Use for custom configuration

### Changing Branding
Edit files in `branding/`:
- `grub-theme/` - GRUB boot menu theme
- `plymouth-theme/` - Boot splash animation
- `wallpapers/` - Background images

## Troubleshooting

### Build Fails with "package not found"
- Check package names match Ubuntu 24.04
- Run `apt-cache search <package>` to verify

### Out of Memory
- Increase swap space: `sudo swapon -a`
- Reduce parallel builds in live-build config

### GPG Key Errors
```bash
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys <KEY>
```

### Live Boot Issues
- Verify ISO integrity: `md5sum OmniLinux-*.iso`
- Check syslinux/grub configuration
- Try adding `nomodeset` to kernel parameters

## Advanced: Build with Docker

```dockerfile
FROM ubuntu:24.04
RUN apt-get update && apt-get install -y live-build
COPY . /build
WORKDIR /build
RUN lb config && lb bootstrap && lb chroot && lb build
```

## Testing the ISO

### VM Testing (QEMU)
```bash
qemu-system-x86_64 -m 4096 -cdrom OmniLinux-1.0-LTS-amd64.iso
```

### USB Testing
```bash
sudo dd if=OmniLinux-1.0-LTS-amd64.iso of=/dev/sdX bs=4M status=progress
```

## Build Output

After successful build:
- `OmniLinux-1.0-LTS-amd64.iso` - Bootable ISO (~3-4GB)
- Can be flashed to USB or burned to DVD
- Tested in VM before physical hardware