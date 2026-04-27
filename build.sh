#!/bin/bash

set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_ok() { echo -e "${GREEN}[OK]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_err() { echo -e "${RED}[ERROR]${NC} $1"; }

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

ARCH="${1:-amd64}"

log_info "Building OmniLinux for: $ARCH"

if [ "$EUID" -ne 0 ]; then
    log_err "Run as root: sudo ./build.sh"
    exit 1
fi

log_info "Installing dependencies..."
export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install -y --no-install-recommends \
    live-build \
    debootstrap \
    squashfs-tools \
    xorriso \
    mtools \
    git \
    wget \
    gzip \
    live-boot \
    live-boot-initramfs-tools

log_info "Cleaning previous build..."
lb clean --all 2>/dev/null || true
rm -f OmniLinux-*.iso 2>/dev/null || true
rm -rf auto 2>/dev/null || true
rm -rf chroot 2>/dev/null || true

log_info "Configuring for $ARCH..."

# Create auto/config properly
mkdir -p auto
cat > auto/config <<'CONFIGEOF'
#!/bin/bash
lb config noauto \
    --architectures amd64 \
    --mode ubuntu \
    --distribution noble \
    --mirror-bootstrap "http://archive.ubuntu.com/ubuntu/" \
    --mirror-binary "http://archive.ubuntu.com/ubuntu/" \
    --archive-areas "main restricted universe multiverse" \
    --iso-application "OmniLinux" \
    --iso-publisher "OmniLinux Project" \
    --iso-volume "OmniLinux 1.0 LTS" \
    --bootappend-live "boot=live config toram" \
    --linux-packages "linux-image-generic-hwe-24.04" \
    --initramfs "initramfs-tools" \
    --system live \
    --source false \
    --binary-images iso-hybrid
CONFIGEOF
chmod +x auto/config

# Create auto/bootstrap - with debug
cat > auto/bootstrap <<'BOOTEOF'
#!/bin/bash
set -x
lb bootstrap noauto "${@}"
BOOTEOF
chmod +x auto/bootstrap

# Create auto/chroot - with debug
cat > auto/chroot <<'CHROOTEOF'
#!/bin/bash
set -x
lb chroot noauto "${@}"
CHROOTEOF
chmod +x auto/chroot

# Create auto/binary - with debug
cat > auto/binary <<'BINARYEOF'
#!/bin/bash
set -x
lb binary noauto "${@}"
BINARYEOF
chmod +x auto/binary

log_info "[1/4] Bootstrapping base system..."
log_warn "Downloading Ubuntu base (~400MB)..."
lb bootstrap --debug || {
    log_err "Bootstrap failed, checking error..."
    ls -la
    cat config/bootstrap 2>/dev/null || true
}

log_info "[2/4] Installing packages..."
log_warn "This takes 15-30 minutes..."
lb chroot --verbose

log_info "[3/4] Building ISO..."
log_warn "Creating squashfs and ISO..."
lb build

log_info "[4/4] Finalizing..."
ISO_NAME="OmniLinux-1.0-LTS-$ARCH.iso"
mv live-image-*.hybrid.iso "$ISO_NAME" 2>/dev/null || \
mv live-image-*.iso "$ISO_NAME" 2>/dev/null || true

if [ -f "$ISO_NAME" ]; then
    sha256sum "$ISO_NAME" > "$ISO_NAME.sha256"
    SIZE=$(du -h "$ISO_NAME" | cut -f1)
    log_ok "========================================"
    log_ok "Build Complete!"
    log_ok "ISO: $ISO_NAME"
    log_ok "Size: $SIZE"
    log_ok "========================================"
else
    log_err "ISO not found!"
    exit 1
fi