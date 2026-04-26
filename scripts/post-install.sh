#!/bin/bash

# post-install.sh
# OmniLinux First-Boot Setup Wizard

set -e

if [ "$EUID" -ne 0 ]; then
    echo "Please run with sudo."
    exit 1
fi

echo "========================================="
echo "   Welcome to OmniLinux Setup!          "
echo "========================================="

echo "[*] Updating package caches..."
apt-get update

echo "[*] Installing Flatpak applications..."
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo 2>/dev/null || true
flatpak install -y flathub md.obsidian.Obsidian 2>/dev/null || true
flatpak install -y flathub com.discordapp.Discord 2>/dev/null || true

echo "[*] Generating SSH keys..."
ssh-keygen -A 2>/dev/null || true

echo "[*] Configuring firewall..."
ufw enable 2>/dev/null || true

echo "========================================="
echo "   Setup Complete!                     "
echo "  Run 'omni-install security-tools'   "
echo "  for advanced security tools        "
echo "========================================="