# Installing OmniLinux

## Minimum Requirements

- CPU: 64-bit dual-core 1.5GHz
- RAM: 2GB (4GB for GNOME/KDE)
- Storage: 20GB
- Display: 1024x768

## Installation Methods

### Method 1: USB Flash Drive (Recommended)

1. Download `OmniLinux-1.0-amd64.iso`
2. Flash with Rufus (Windows) or dd (Linux):
   ```bash
   sudo dd if=OmniLinux-1.0-amd64.iso of=/dev/sdX bs=4M status=progress
   ```
3. Boot from USB
4. Select session (GNOME/KDE/XFCE)
5. Launch "Install OmniLinux" shortcut

### Method 2: Virtual Machine

1. Create VM with at least 30GB storage, 4GB RAM
2. Mount ISO as CD-ROM
3. Boot and select session
4. Install to virtual disk

## Installation Steps

1. Select language
2. Select keyboard layout
3. Choose installation type:
   - **Erase disk** (single boot)
   - **Alongside** (dual boot)
   - **Manual** (custom partitioning)
4. Create user account
5. Choose Desktop Environment
6. Wait for installation (~10-15 min)
7. Reboot and remove USB

## First Boot

1. Run `sudo post-install.sh` for flatpak setup
2. Run `sudo omni-install security-tools` if needed
3. Enjoy OmniLinux!