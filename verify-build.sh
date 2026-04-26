#!/bin/bash
# OmniLinux Build Verification Script
# Checks if all required files and configurations are in place

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

PASS=0
FAIL=0

check_file() {
    if [ -f "$1" ]; then
        echo -e "${GREEN}[OK]${NC} $1 exists"
        ((PASS++))
    else
        echo -e "${RED}[MISSING]${NC} $1 is missing!"
        ((FAIL++))
    fi
}

check_dir() {
    if [ -d "$1" ]; then
        echo -e "${GREEN}[OK]${NC} $1 exists"
        ((PASS++))
    else
        echo -e "${RED}[MISSING]${NC} $1 is missing!"
        ((FAIL++))
    fi
}

echo "============================================"
echo "   OmniLinux Build Verification            "
echo "============================================"
echo ""

echo "--- Core Build Files ---"
check_file "build.sh"
check_file "auto/config"
check_file "auto/bootstrap"
check_file "auto/binary"

echo ""
echo "--- Package Lists ---"
check_dir "config/package-lists"
for list in config/package-lists/*.list.chroot; do
    if [ -f "$list" ]; then
        echo -e "${GREEN}[OK]${NC} $list ($(wc -l < "$list") packages)"
        ((PASS++))
    fi
done

echo ""
echo "--- Hooks ---"
check_dir "config/hooks/live"
for hook in config/hooks/live/*.hook.chroot; do
    if [ -f "$hook" ]; then
        echo -e "${GREEN}[OK]${NC} $(basename $hook)"
        ((PASS++))
    fi
done

echo ""
echo "--- Includes ---"
check_dir "config/includes.chroot/etc"
check_dir "config/includes.chroot/usr"
check_dir "config/includes.binary/isolinux"
check_file "config/includes.chroot/etc/omnilinux-release"

echo ""
echo "--- Branding ---"
check_dir "branding/grub-theme"
check_dir "branding/plymouth-theme"
check_dir "branding/wallpapers"
check_file "branding/grub-theme/theme.txt"
check_file "branding/plymouth-theme/omnilinux.plymouth"

echo ""
echo "--- Scripts ---"
check_dir "scripts"
for script in scripts/*.sh; do
    if [ -f "$script" ]; then
        echo -e "${GREEN}[OK]${NC} $(basename $script)"
        ((PASS++))
    fi
done

echo ""
echo "--- Documentation ---"
check_file "README.md"
check_file "docs/BUILD.md"
check_file "docs/INSTALL.md"
check_file "AGENTS.md"

echo ""
echo "============================================"
echo "Results: ${GREEN}${PASS} passed${NC}, ${RED}${FAIL} failed${NC}"
echo "============================================"

if [ $FAIL -gt 0 ]; then
    echo -e "${YELLOW}Some required files are missing!${NC}"
    exit 1
else
    echo -e "${GREEN}All required files are in place!${NC}"
    echo "You can now run: sudo ./build.sh"
    exit 0
fi