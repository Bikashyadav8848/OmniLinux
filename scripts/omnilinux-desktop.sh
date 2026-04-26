#!/bin/bash
# OmniLinux Desktop Environment Installer
# Allows installation of additional desktop environments

set -e

if [ "$EUID" -ne 0 ]; then
    echo "Please run as root"
    exit 1
fi

DESKTOP=$1

case $DESKTOP in
    gnome)
        echo "Installing GNOME Desktop..."
        DEBIAN_FRONTEND=noninteractive apt-get install -y gnome-shell gdm3 gnome-session gnome-control-center nautilus
        ;;
    kde)
        echo "Installing KDE Plasma..."
        DEBIAN_FRONTEND=noninteractive apt-get install -y kde-plasma-desktop sddm
        ;;
    xfce)
        echo "Installing XFCE..."
        DEBIAN_FRONTEND=noninteractive apt-get install -y xfce4 xfce4-goodies lightdm
        ;;
    cinnamon)
        echo "Installing Cinnamon..."
        DEBIAN_FRONTEND=noninteractive apt-get install -y cinnamon cinnamon-desktop-environment lightdm
        ;;
    mate)
        echo "Installing MATE..."
        DEBIAN_FRONTEND=noninteractive apt-get install -y mate-desktop-environment mate-desktop-environment-extras lightdm
        ;;
    all)
        echo "Installing all desktops..."
        DEBIAN_FRONTEND=noninteractive apt-get install -y gnome-shell gdm3 kde-plasma-desktop sddm xfce4 lightdm
        ;;
    *)
        echo "Usage: sudo omnilinux-desktop [gnome|kde|xfce|cinnamon|mate|all]"
        exit 1
        ;;
esac

echo "Desktop installation complete. Logout and select your desktop at login screen."