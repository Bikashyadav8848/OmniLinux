#!/bin/bash
# OmniLinux Universal Build Script

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

ARCH="${1:-amd64}"
VARIANT="${2:-desktop}"

log_info "Building OmniLinux for: $ARCH"

if [ "$EUID" -ne 0 ]; then
    log_err "Run as root: sudo ./build.sh"
    exit 1
fi

log_info "Installing dependencies..."
apt-get update
DEPS="live-build debootstrap squashfs-tools xorriso mtools git curl wget"
apt-get install -y --no-install-recommends $DEPS

log_info "Cleaning previous build..."
lb clean --all 2>/dev/null || true
rm -f OmniLinux-*.iso 2>/dev/null || true

log_info "Configuring for $ARCH..."
cat > auto/config <<'EOF'
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
    --iso-volume "OmniLinux 1.0 LTS" \
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

log_info "[1/4] Bootstrapping base system..."
log_warn "Downloading Ubuntu base (~300MB)..."
lb bootstrap

log_info "[2/4] Installing packages..."
log_warn "This takes 15-30 minutes..."
lb chroot

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