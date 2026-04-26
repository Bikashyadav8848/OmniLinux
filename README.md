# OmniLinux 1.0 LTS

A modern, all-in-one Linux distribution built for productivity, development, security, and gaming.

## Features

- **6 Desktop Environments**: GNOME 46, KDE Plasma 6, XFCE 4.18, Cinnamon, MATE, LXQt
- **Multi-Architecture**: amd64, i386, arm64, armhf, riscv64, ppc64el
- **Pre-installed Tools**: Dev, Security, Gaming stacks
- **Modern Stack**: Wayland, Pipewire
- **Secure by Default**: UFW, AppArmor enabled

## Supported Devices

| Architecture | Devices | Status |
|---------------|---------|--------|
| **amd64** | Intel/AMD PC, Laptop, Desktop | ✅ Full |
| **i386** | Old 32-bit PCs | ✅ Full |
| **arm64** | RPi 4/5, Pine64, Odroid, Mac M1/M2 | ✅ Full |
| **armhf** | RPi 2/3, Zero, Generic ARM | ✅ Full |
| **riscv64** | RISC-V boards | ✅ Full |
| **ppc64el** | PowerPC Macs, IBM | ✅ Full |

## Quick Start

```bash
# Install build tools
sudo apt install live-build debootstrap squashfs-tools xorriso grub-efi-amd64 mtools

# Build for your device
sudo ./build.sh

# Or select from menu
sudo ./build.sh
# Then select device type
```

## Build Options

```bash
# Build for specific architecture
sudo ./build.sh amd64
sudo ./build.sh arm64
sudo ./build.sh i386
sudo ./build.sh armhf

# Build all
sudo ./build.sh all
```

## Output

- `OmniLinux-1.0-LTS-amd64.iso` (~3-4GB)
- `OmniLinux-1.0-LTS-arm64.iso` (~3GB)
- `OmniLinux-1.0-LTS-i386.iso` (~2.5GB)
- `OmniLinux-1.0-LTS-armhf.iso` (~2GB)

## Project Structure

```
OmniLinux/
├── build.sh              # Main build script (multi-arch)
├── auto/                 # live-build config
│   ├── config           # Build configuration
│   ├── bootstrap        # Base system bootstrap
│   ├── chroot           # Package installation
│   └── binary            # ISO creation
├── config/
│   ├── package-lists/  # Package definitions (01-19)
│   ├── hooks/live/      # Build hooks
│   └── includes.chroot/ # System files
├── branding/            # Themes & wallpapers
├── scripts/            # Helper tools
└── docs/               # Documentation
```

## Documentation

- [Building](docs/BUILD.md)
- [Installation](docs/INSTALL.md)
- [Contributing](docs/CONTRIBUTING.md)

## Website

https://omnilinux.org

## License

MIT