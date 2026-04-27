#!/bin/bash

# omni-install.sh
# Helper CLI tool to install additional stacks

set -e

if [ "$1" == "" ]; then
    echo "OmniLinux Package Installer"
    echo "Usage: sudo omni-install [module]"
    echo ""
    echo "Available modules:"
    echo "  security-tools  - Install advanced Kali-compatible security tools"
    echo "  devops-tools   - Install Kubernetes/DevOps tools"
    echo "  gaming-tools  - Install Steam, Lutris, Wine, Proton"
    echo "  media-tools  - Install media production tools"
    exit 0
fi

if [ "$EUID" -ne 0 ]; then
    echo "Please run as root (sudo omni-install)"
    exit 1
fi

MODULE=$1

case $MODULE in
    security-tools)
        echo "[*] Installing Security Tools..."
        apt-get update
        apt-get install -y nmap wireshark aircrack-ng john hydra sqlmap gobuster netcat-traditional
        echo "[*] Security tools installed."
        ;;
    devops-tools)
        echo "[*] Installing DevOps Tools..."
        curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
        install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
        rm kubectl
        curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
        install -o root -g root -m 0755 minikube-linux-amd64 /usr/local/bin/minikube
        rm minikube-linux-amd64
        echo "[*] DevOps tools installed."
        ;;
    gaming-tools)
        echo "[*] Installing Gaming Tools..."
        add-apt-repository -y ppa:lutris-team/lutris 2>/dev/null || true
        add-apt-repository -y ppa:cybermax-deks/sdl2-backport 2>/dev/null || true
        apt-get update
        apt-get install -y lutris gamemode mangohud obs-studio
        echo "[*] Gaming tools installed."
        ;;
    media-tools)
        echo "[*] Installing Media Tools..."
        apt-get update
        apt-get install -y kdenlive blender audacity obs-studio
        echo "[*] Media tools installed."
        ;;
    *)
        echo "Unknown module: $MODULE"
        echo "Valid modules: security-tools, devops-tools, gaming-tools, media-tools"
        exit 1
        ;;
esac

echo "[*] Done."