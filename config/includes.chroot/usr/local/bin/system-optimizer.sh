#!/bin/bash

# system-optimizer.sh
# Real-time performance optimizations for OmniLinux

set -e

if [ "$EUID" -ne 0 ]; then
    echo "Please run as root (sudo system-optimizer.sh)"
    exit 1
fi

MODE=${1:-performance}

case $MODE in
    performance)
        echo "[*] Applying performance mode optimizations..."
        echo 3 > /proc/sys/vm/drop_caches 2>/dev/null || true
        
        if command -v cpupower >/dev/null 2>&1; then
            cpupower frequency-set -g performance 2>/dev/null || true
        fi
        
        sysctl -w vm.swappiness=10 2>/dev/null || true
        ulimit -n 1048576 2>/dev/null || true
        echo "[+] Performance mode enabled."
        ;;
    powersave)
        echo "[*] Applying powersave mode..."
        if command -v cpupower >/dev/null 2>&1; then
            cpupower frequency-set -g powersave 2>/dev/null || true
        fi
        sysctl -w vm.swappiness=100 2>/dev/null || true
        echo "[+] Powersave mode enabled."
        ;;
    *)
        echo "Usage: sudo system-optimizer.sh [performance|powersave]"
        exit 1
        ;;
esac

echo "[*] Optimization complete."