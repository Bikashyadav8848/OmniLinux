#!/bin/bash
# OmniLinux Build Script
# Builds a bootable ISO using live-build on Ubuntu

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
apt-get install -y --no-install-recommends live-build debootstrap squashfs-tools xorriso mtools git wget gzip

log_info "Cleaning previous build..."
lb clean --all 2>/dev/null || true
rm -f OmniLinux-*.iso 2>/dev/null || true
rm -rf chroot auto .build 2>/dev/null || true

log_info "Configuring for $ARCH..."
mkdir -p auto

# Generate auto/config without using complex backslashes in heredoc
cat > auto/config <<'CONFIGEOF'
#!/bin/bash
lb config noauto \
    --architectures amd64 \
    --distribution noble \
    --mode ubuntu \
    --parent-distribution noble \
    --parent-mirror-bootstrap "http://archive.ubuntu.com/ubuntu/" \
    --parent-mirror-chroot "http://archive.ubuntu.com/ubuntu/" \
    --parent-mirror-binary "http://archive.ubuntu.com/ubuntu/" \
    --mirror-bootstrap "http://archive.ubuntu.com/ubuntu/" \
    --mirror-chroot "http://archive.ubuntu.com/ubuntu/" \
    --mirror-binary "http://archive.ubuntu.com/ubuntu/" \
    --archive-areas "main restricted universe multiverse" \
    --parent-archive-areas "main restricted universe multiverse" \
    --iso-application "OmniLinux" \
    --iso-publisher "OmniLinux Project" \
    --iso-volume "OmniLinux 1.0 LTS" \
    --bootappend-live "boot=live components quiet splash" \
    --linux-packages "linux-image linux-headers" \
    --linux-flavours "generic" \
    --initramfs auto \
    --system live \
    --source false \
    --binary-images iso-hybrid \
    --apt-recommends false \
    --security true \
    --updates true \
    "${@}"
CONFIGEOF
chmod +x auto/config

# Generate other auto scripts
echo '#!/bin/bash' > auto/bootstrap && echo 'lb bootstrap noauto "${@}"' >> auto/bootstrap
echo '#!/bin/bash' > auto/chroot && echo 'lb chroot noauto "${@}"' >> auto/chroot
echo '#!/bin/bash' > auto/binary && echo 'lb binary noauto "${@}"' >> auto/binary
chmod +x auto/bootstrap auto/chroot auto/binary

log_info "[0/4] Running lb config..."
lb config

log_info "[1/4] Bootstrapping base system..."
log_warn "Downloading Ubuntu base... This can take a while."
lb bootstrap 2>&1 | tee bootstrap.log | tail -n 50
if [ ${PIPESTATUS[0]} -ne 0 ]; then
    log_err "Bootstrap failed! Checking logs..."
    tail -n 100 chroot/debootstrap/debootstrap.log 2>/dev/null || true
    exit 1
fi

log_info "[2/4] Installing packages..."
log_warn "This takes 15-30 minutes..."
lb chroot 2>&1 | tee chroot.log | tail -n 50

log_info "[3/4] Building ISO..."
log_warn "Creating squashfs and ISO..."
lb binary 2>&1 | tee binary.log | tail -n 50

log_info "[4/4] Finalizing..."
ISO_NAME="OmniLinux-1.0-LTS-$ARCH.iso"
mv live-image-*.hybrid.iso "$ISO_NAME" 2>/dev/null || \
mv live-image-*.iso "$ISO_NAME" 2>/dev/null || \
mv *.hybrid.iso "$ISO_NAME" 2>/dev/null || true

if [ -f "$ISO_NAME" ]; then
    sha256sum "$ISO_NAME" > "$ISO_NAME.sha256"
    log_ok "========================================"
    log_ok "Build Complete: $ISO_NAME"
    log_ok "========================================"
else
    log_err "ISO not found!"
    ls -la *.iso 2>/dev/null || ls -la
    exit 1
fi