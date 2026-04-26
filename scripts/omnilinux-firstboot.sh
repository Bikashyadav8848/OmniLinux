#!/bin/bash
# OmniLinux First-Boot Setup Script
# Runs after initial installation

set -e

if [ "$EUID" -ne 0 ]; then
    echo "Please run with sudo"
    exit 1
fi

echo "============================================"
echo "   Welcome to OmniLinux Setup Wizard!    "
echo "============================================"
echo ""

# Update system
echo "[*] Updating package cache..."
apt-get update -qq

# Add Flatpak repository
echo "[*] Adding Flatpak support..."
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo 2>/dev/null || true

# Install recommended Flatpak apps
echo "[*] Installing recommended applications..."
flatpak install -y flathub org.obsproject.Studio 2>/dev/null || true
flatpak install -y flathub com.discordapp.Discord 2>/dev/null || true
flatpak install -y flathub md.obsidian.Obsidian 2>/dev/null || true
flatpak install -y flathub org.kde.kdenlive 2>/dev/null || true

# Generate SSH keys
echo "[*] Generating SSH keys..."
ssh-keygen -A 2>/dev/null || true

# Configure firewall
echo "[*] Configuring firewall (UFW)..."
ufw default deny incoming 2>/dev/null || true
ufw default allow outgoing 2>/dev/null || true
ufw enable 2>/dev/null || true

# Set timezone
echo "[*] Setting timezone..."
timedatectl set-timezone UTC 2>/dev/null || true

# Enable TRIM for SSDs
echo "[*] Enabling SSD trim (fstrim)..."
systemctl enable fstrim.timer 2>/dev/null || true
systemctl start fstrim.timer 2>/dev/null || true

# Update desktop database
echo "[*] Updating desktop database..."
update-desktop-database 2>/dev/null || true

echo ""
echo "============================================"
echo "  Setup Complete!"
echo "============================================"
echo ""
echo "Run these commands to install additional tools:"
echo "  sudo omni-install security-tools  # Security tools"
echo "  sudo omni-install devops-tools    # DevOps tools"
echo "  sudo omni-install gaming-tools    # Gaming tools"
echo ""
echo "Enjoy OmniLinux!"