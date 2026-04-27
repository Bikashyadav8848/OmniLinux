#!/bin/bash
# ============================================================
# OmniLinux Hardware Auto-Tuning Script
# Detects hardware and applies optimal performance settings
# ============================================================

set -euo pipefail

# Colors
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BOLD='\033[1m'
NC='\033[0m'

log_info()  { echo -e "${CYAN}[OMNI-TUNE]${NC} $1"; }
log_ok()    { echo -e "${GREEN}[✅ DONE]${NC} $1"; }
log_warn()  { echo -e "${YELLOW}[⚠️  WARN]${NC} $1"; }

echo -e "${CYAN}"
echo "╔══════════════════════════════════════════════════════╗"
echo "║       ⚡ OmniLinux Hardware Auto-Tuner               ║"
echo "║    Detecting & optimizing your hardware...           ║"
echo "╚══════════════════════════════════════════════════════╝"
echo -e "${NC}"

# ──────────────────────────────────────────────────────────────
# CPU Detection & Optimization
# ──────────────────────────────────────────────────────────────
tune_cpu() {
    log_info "Detecting CPU..."
    
    local cpu_vendor=$(grep -m1 'vendor_id' /proc/cpuinfo | awk '{print $3}')
    local cpu_model=$(grep -m1 'model name' /proc/cpuinfo | sed 's/model name\s*:\s*//')
    local cpu_cores=$(nproc)
    
    log_info "CPU: ${cpu_model} (${cpu_cores} cores, vendor: ${cpu_vendor})"
    
    # Set CPU governor based on power source
    if [ -d /sys/class/power_supply/BAT0 ] || [ -d /sys/class/power_supply/BAT1 ]; then
        local battery_status=$(cat /sys/class/power_supply/BAT*/status 2>/dev/null | head -1)
        if [ "$battery_status" = "Discharging" ]; then
            log_info "On battery — using 'schedutil' governor"
            echo "schedutil" | tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor > /dev/null 2>&1 || true
        else
            log_info "On AC power — using 'performance' governor"
            echo "performance" | tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor > /dev/null 2>&1 || true
        fi
    else
        log_info "Desktop detected — using 'performance' governor"
        echo "performance" | tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor > /dev/null 2>&1 || true
    fi
    
    # Enable turbo boost
    if [ -f /sys/devices/system/cpu/intel_pstate/no_turbo ]; then
        echo 0 > /sys/devices/system/cpu/intel_pstate/no_turbo 2>/dev/null || true
        log_info "Intel Turbo Boost enabled"
    fi
    
    if [ "$cpu_vendor" = "AuthenticAMD" ]; then
        # AMD-specific: enable Precision Boost
        if [ -f /sys/devices/system/cpu/amd_pstate/status ]; then
            echo "active" > /sys/devices/system/cpu/amd_pstate/status 2>/dev/null || true
            log_info "AMD P-State active mode enabled"
        fi
    fi
    
    log_ok "CPU optimization applied"
}

# ──────────────────────────────────────────────────────────────
# Memory Optimization
# ──────────────────────────────────────────────────────────────
tune_memory() {
    log_info "Optimizing memory management..."
    
    local total_ram_kb=$(grep MemTotal /proc/meminfo | awk '{print $2}')
    local total_ram_mb=$((total_ram_kb / 1024))
    local total_ram_gb=$((total_ram_mb / 1024))
    
    log_info "Total RAM: ${total_ram_gb} GB (${total_ram_mb} MB)"
    
    # Swappiness — lower for more RAM, higher for less
    if [ $total_ram_gb -ge 16 ]; then
        sysctl -w vm.swappiness=10 > /dev/null
        log_info "Swappiness set to 10 (plenty of RAM)"
    elif [ $total_ram_gb -ge 8 ]; then
        sysctl -w vm.swappiness=30 > /dev/null
        log_info "Swappiness set to 30"
    else
        sysctl -w vm.swappiness=60 > /dev/null
        log_info "Swappiness set to 60 (low RAM, using zram)"
    fi
    
    # VFS cache pressure
    sysctl -w vm.vfs_cache_pressure=50 > /dev/null
    
    # Dirty ratio tuning
    sysctl -w vm.dirty_ratio=15 > /dev/null
    sysctl -w vm.dirty_background_ratio=5 > /dev/null
    
    # Enable MGLRU if available
    if [ -f /sys/kernel/mm/lru_gen/enabled ]; then
        echo 5 > /sys/kernel/mm/lru_gen/enabled 2>/dev/null || true
        log_info "MGLRU enabled"
    fi
    
    # Transparent Huge Pages
    if [ -f /sys/kernel/mm/transparent_hugepage/enabled ]; then
        echo "always" > /sys/kernel/mm/transparent_hugepage/enabled 2>/dev/null || true
        log_info "Transparent Huge Pages enabled"
    fi
    
    log_ok "Memory optimization applied"
}

# ──────────────────────────────────────────────────────────────
# zram Setup
# ──────────────────────────────────────────────────────────────
setup_zram() {
    log_info "Configuring zram (compressed swap in RAM)..."
    
    local total_ram_kb=$(grep MemTotal /proc/meminfo | awk '{print $2}')
    local zram_size_kb=$((total_ram_kb / 2))  # 50% of RAM
    
    # Load zram module
    modprobe zram num_devices=1 2>/dev/null || true
    
    if [ -e /dev/zram0 ]; then
        # Reset if already configured
        echo 1 > /sys/block/zram0/reset 2>/dev/null || true
        
        # Set compression algorithm
        echo "zstd" > /sys/block/zram0/comp_algorithm 2>/dev/null || true
        
        # Set size
        echo "${zram_size_kb}K" > /sys/block/zram0/disksize 2>/dev/null || true
        
        # Make swap
        mkswap /dev/zram0 > /dev/null 2>&1 || true
        swapon -p 100 /dev/zram0 2>/dev/null || true
        
        log_ok "zram configured: $((zram_size_kb / 1024)) MB with zstd compression"
    else
        log_warn "zram device not available"
    fi
}

# ──────────────────────────────────────────────────────────────
# I/O Scheduler Auto-Detection
# ──────────────────────────────────────────────────────────────
tune_io() {
    log_info "Auto-detecting storage devices and setting I/O schedulers..."
    
    for device in /sys/block/sd* /sys/block/nvme* /sys/block/vd*; do
        [ -d "$device" ] || continue
        local dev_name=$(basename "$device")
        local scheduler_file="$device/queue/scheduler"
        
        [ -f "$scheduler_file" ] || continue
        
        local rotational=$(cat "$device/queue/rotational" 2>/dev/null || echo "0")
        
        if echo "$dev_name" | grep -q "nvme"; then
            # NVMe — no scheduler needed
            echo "none" > "$scheduler_file" 2>/dev/null || true
            log_info "  ${dev_name}: NVMe → scheduler: none"
        elif [ "$rotational" = "0" ]; then
            # SSD — use kyber
            echo "kyber" > "$scheduler_file" 2>/dev/null || true
            log_info "  ${dev_name}: SSD → scheduler: kyber"
        else
            # HDD — use bfq
            echo "bfq" > "$scheduler_file" 2>/dev/null || true
            log_info "  ${dev_name}: HDD → scheduler: bfq"
        fi
    done
    
    log_ok "I/O schedulers optimized"
}

# ──────────────────────────────────────────────────────────────
# GPU Detection & Setup
# ──────────────────────────────────────────────────────────────
tune_gpu() {
    log_info "Detecting GPU..."
    
    local gpu_info=$(lspci 2>/dev/null | grep -i 'vga\|3d\|display' || echo "Unknown")
    
    if echo "$gpu_info" | grep -qi "nvidia"; then
        log_info "NVIDIA GPU detected: $gpu_info"
        log_info "  → Use 'omni-gpu-setup nvidia' to install proprietary drivers"
        
        # Set NVIDIA performance mode if driver loaded
        if command -v nvidia-smi &>/dev/null; then
            nvidia-smi -pm 1 2>/dev/null || true
            log_info "  → NVIDIA persistence mode enabled"
        fi
        
    elif echo "$gpu_info" | grep -qi "amd\|radeon"; then
        log_info "AMD GPU detected: $gpu_info"
        log_info "  → Using open-source Mesa/RADV drivers (optimal)"
        
        # AMD power profile
        if [ -f /sys/class/drm/card0/device/power_dpm_force_performance_level ]; then
            echo "auto" > /sys/class/drm/card0/device/power_dpm_force_performance_level 2>/dev/null || true
        fi
        
    elif echo "$gpu_info" | grep -qi "intel"; then
        log_info "Intel GPU detected: $gpu_info"
        log_info "  → Using Intel Mesa drivers"
    else
        log_warn "GPU not detected or using generic driver"
    fi
    
    log_ok "GPU detection complete"
}

# ──────────────────────────────────────────────────────────────
# Network Optimization
# ──────────────────────────────────────────────────────────────
tune_network() {
    log_info "Optimizing network stack..."
    
    # TCP BBR congestion control
    sysctl -w net.core.default_qdisc=fq > /dev/null 2>&1 || true
    sysctl -w net.ipv4.tcp_congestion_control=bbr > /dev/null 2>&1 || true
    
    # TCP Fast Open
    sysctl -w net.ipv4.tcp_fastopen=3 > /dev/null 2>&1 || true
    
    # Increase buffer sizes
    sysctl -w net.core.rmem_max=16777216 > /dev/null 2>&1 || true
    sysctl -w net.core.wmem_max=16777216 > /dev/null 2>&1 || true
    sysctl -w net.ipv4.tcp_rmem="4096 87380 16777216" > /dev/null 2>&1 || true
    sysctl -w net.ipv4.tcp_wmem="4096 65536 16777216" > /dev/null 2>&1 || true
    
    # Connection tracking
    sysctl -w net.core.somaxconn=8192 > /dev/null 2>&1 || true
    sysctl -w net.core.netdev_max_backlog=16384 > /dev/null 2>&1 || true
    
    log_ok "Network optimization applied (BBR + TCP Fast Open)"
}

# ──────────────────────────────────────────────────────────────
# System Report
# ──────────────────────────────────────────────────────────────
print_report() {
    echo ""
    echo -e "${CYAN}╔══════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║           ⚡ OmniLinux System Report                ║${NC}"
    echo -e "${CYAN}╠══════════════════════════════════════════════════════╣${NC}"
    echo -e "${CYAN}║${NC} CPU:     $(grep -m1 'model name' /proc/cpuinfo | sed 's/model name\s*:\s*//' | cut -c1-44)"
    echo -e "${CYAN}║${NC} Cores:   $(nproc) cores"
    echo -e "${CYAN}║${NC} RAM:     $(($(grep MemTotal /proc/meminfo | awk '{print $2}') / 1024)) MB"
    echo -e "${CYAN}║${NC} Kernel:  $(uname -r)"
    echo -e "${CYAN}║${NC} Governor: $(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor 2>/dev/null || echo 'N/A')"
    echo -e "${CYAN}║${NC} Swap:    $(swapon --show=SIZE --noheadings 2>/dev/null | head -1 || echo 'None')"
    echo -e "${CYAN}║${NC} TCP:     $(sysctl -n net.ipv4.tcp_congestion_control 2>/dev/null || echo 'N/A')"
    echo -e "${CYAN}╚══════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${GREEN}⚡ OmniLinux is tuned for maximum performance!${NC}"
}

# ──────────────────────────────────────────────────────────────
# Main
# ──────────────────────────────────────────────────────────────
main() {
    # Check root
    if [ "$(id -u)" -ne 0 ]; then
        log_warn "Some optimizations require root. Run with sudo for full tuning."
    fi
    
    tune_cpu
    tune_memory
    setup_zram
    tune_io
    tune_gpu
    tune_network
    print_report
}

main "$@"
