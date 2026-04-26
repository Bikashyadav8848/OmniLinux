#!/bin/bash
# OmniLinux Universal Build Script
# Supports ALL architectures and devices

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_ok() { echo -e "${GREEN}[OK]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_err() { echo -e "${RED}[ERROR]${NC} $1"; }

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Detect if arguments passed
ARCH="${1:-menu}"
VARIANT="${2:-desktop}"

if [ "$ARCH" = "menu" ]; then
    show_device_menu
else
    build_for_device "$ARCH" "$VARIANT"
fi

show_device_menu() {
    echo ""
    echo "========================================"
    echo "  OmniLinux Universal Build System"
    echo "========================================"
    echo ""
    echo "Available Devices/Architectures:"
    echo ""
    echo " [1] amd64       - Intel/AMD 64-bit PC/Laptop"
    echo " [2] i386       - Intel/AMD 32-bit Old PC"
    echo " [3] arm64      - ARM 64-bit (RPi 4/5, Pine64, Mac M1/M2)"
    echo " [4] armhf      - ARM 32-bit (RPi 2/3/Zero)"
    echo " [5] riscv64    - RISC-V 64-bit"
    echo " [6] ppc64el    - PowerPC 64-bit"
    echo " [7] s390x      - IBM Z systems"
    echo ""
    echo " [8] all        - Build ALL architectures"
    echo ""
    read -p "Select device [1-8]: " choice
    
    case $choice in
        1) build_for_device "amd64" ;;
        2) build_for_device "i386" ;;
        3) build_for_device "arm64" ;;
        4) build_for_device "armhf" ;;
        5) build_for_device "riscv64" ;;
        6) build_for_device "ppc64el" ;;
        7) build_for_device "s390x" ;;
        8) build_all ;;
        *) build_for_device "amd64" ;;
    esac
}

build_all() {
    log_info "Building all architectures..."
    for arch in amd64 i386 arm64 armhf; do
        build_for_device "$arch"
    done
    log_ok "All builds complete!"
    ls -lh OmniLinux-*.iso
}

build_for_device() {
    ARCH="$1"
    VARIANT="${2:-desktop}"
    
    # Validate architecture
    SUPPORTED_ARCHS="amd64 i386 arm64 armhf riscv64 ppc64el s390x"
    if ! echo "$SUPPORTED_ARCHS" | grep -q "$ARCH"; then
        log_err "Unsupported architecture: $ARCH"
        return 1
    fi
    
    log_info "========================================"
    log_info "Building OmniLinux for: $ARCH"
    log_info "========================================"
    
    # Root check
    if [ "$EUID" -ne 0 ]; then
        log_err "Run as root: sudo ./build.sh"
        exit 1
    fi
    
    # Install deps
    install_deps
    
    # Clean
    log_info "[1/6] Cleaning..."
    lb clean --all 2>/dev/null || true
    rm -f OmniLinux-*.iso 2>/dev/null || true
    
    # Configure
    log_info "[2/6] Configuring for $ARCH..."
    configure_for_arch
    
    # Bootstrap
    log_info "[3/6] Bootstrapping..."
    log_warn "Downloading Ubuntu base (~300-500MB)..."
    lb bootstrap
    
    # Install packages
    log_info "[4/6] Installing packages..."
    log_warn "This takes 20-60 minutes..."
    lb chroot
    
    # Build ISO
    log_info "[5/6] Building ISO..."
    log_warn "Creating squashfs and ISO..."
    lb build
    
    # Finalize
    log_info "[6/6] Finalizing..."
    finalize_build
    
    log_ok "========================================"
    log_ok "Build Complete: $(ls OmniLinux-*.iso 2>/dev/null | head -1)"
    log_ok "========================================"
}

install_deps() {
    log_info "Checking dependencies..."
    
    # Core deps
    DEPS="live-build debootstrap squashfs-tools xorriso mtools git curl wget"
    
    # Arch-specific deps
    case $ARCH in
        arm64|armhf) DEPS="$DEPS gcc-aarch64-linux-gnu qemu-user-static" ;;
        riscv64) DEPS="$DEPS gcc-riscv64-linux-gnu qemu-user-static" ;;
        ppc64el) DEPS="$DEPS gcc-powerpc64-linux-gnu" ;;
    esac
    
    MISSING=""
    for pkg in $DEPS; do
        if ! dpkg -l $pkg &> /dev/null 2>&1; then
            MISSING="$MISSING $pkg"
        fi
    done
    
    if [ -n "$MISSING" ]; then
        log_info "Installing: $MISSING"
        apt-get update
        apt-get install -y $MISSING
    fi
}

configure_for_arch() {
    # Create architecture-specific config
    cat > auto/config <<EOF
#!/bin/bash
lb config noauto \
    --architectures $ARCH \
    --mode debian \
    --distribution noble \
    --archive-areas "main restricted universe multiverse" \
    --mirror-bootstrap "http://archive.ubuntu.com/ubuntu/" \
    --mirror-binary "http://archive.ubuntu.com/ubuntu/" \
    --iso-application "OmniLinux" \
    --iso-publisher "OmniLinux Project" \
    --iso-volume "OmniLinux 1.0 LTS $ARCH" \
    --bootappend-live "boot=live components quiet splash" \
    --linux-packages "linux-image-generic" \
    --initramfs "initramfs-tools" \
    --security true \
    --updates true \
    --system live \
    --source false \
    --binary-images iso-hybrid \
    --uefi true
EOF
    chmod +x auto/config
    
    # Update package lists for architecture
    update_packages_for_arch
}

update_packages_for_arch() {
    case $ARCH in
        i386)
            log_info "Configuring for 32-bit..."
            sed -i 's|linux-image-generic|linux-image-generic-pae|g' config/package-lists/01-base.list.chroot 2>/dev/null || true
            ;;
        arm64)
            log_info "Using ARM64 kernel..."
            ;;
        armhf)
            log_info "Using ARMHF kernel..."
            sed -i '/xfce4/s/^#//' config/package-lists/04-xfce.list.chroot 2>/dev/null || true
            ;;
    esac
}

finalize_build() {
    # Rename ISO with architecture
    ISO_NAME="OmniLinux-1.0-LTS-$ARCH.iso"
    
    mv live-image-*.hybrid.iso "$ISO_NAME" 2>/dev/null || \
    mv live-image-*.iso "$ISO_NAME" 2>/dev/null || true
    
    if [ -f "$ISO_NAME" ]; then
        # Create checksum
        sha256sum "$ISO_NAME" > "$ISO_NAME.sha256"
        SIZE=$(du -h "$ISO_NAME" | cut -f1)
        log_ok "Size: $SIZE"
    else
        log_err "ISO not found!"
    fi
}

# Run if arguments provided
if [ "$ARCH" != "menu" ]; then
    build_for_device "$ARCH" "$VARIANT"
fi