#!/bin/bash

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

DOT_REPO_URL="https://github.com/Calsjunior/dotfiles.git"
WPP_REPO_URL="https://github.com/mylinuxforwork/wallpaper.git"
INSTALL_DIR="$HOME/athena-dotfiles"
WPP_DIR="$HOME/Pictures/Wallpapers"
LOG_FILE="$HOME/caelestia_install_$(date +%Y%m%d_%H%M%S).log"

log() { echo -e "${GREEN}▶${NC} $1" | tee -a "$LOG_FILE"; }
error() { echo -e "${RED}✗${NC} $1" | tee -a "$LOG_FILE"; exit 1; }
warning() { echo -e "${YELLOW}⚠${NC} $1" | tee -a "$LOG_FILE"; }
gaming_info() { echo -e "${BLUE}[GAMING]${NC} $1" | tee -a "$LOG_FILE"; }

clear
echo -e "${GREEN}"
cat << "EOF"
╭────────────────────────────────────────────────────────────────────────────────────────────────╮
│ ▀████    ███                                                 ▀█████████▄             █         │
│   ███    ███                 ▀▀▀▀                              ███    ███          █           │
│   ███    ███    ▄██████▄  ▀███████▄  ▀████████▄   ▄██████▄     ███    ███ ███   ███▀ ▄██████▄  │
│  ▄███▄▄▄▄███▄▄ ███    ███       ▀███  ███    ███ ███    ███   ▄███▄▄▄ ███ ███   ███ ███    ███ │
│ ▀▀███▀▀▀▀███▀  ███    ███  ▄████████  ███    ███ ███    ███  ▀▀███▀▀▀ ███ ███   ███ ███        │
│   ███    ███   ███    ███ ███    ███  ███    ███ ███    ███    ███    ███ ███   ███ ███        │
│   ███    ███   ███    ███ ███    ███  ███    ███ ███    ███    ███    ███ ███   ███ ███    ███ │
│   ███    ████▄  ▀██████▀   ▀████████▄ ███    ███  ▀████████  ▄█████████▀   ▀█████▀   ▀██████▀  │
│                                                        ▄███                                    │
│                                                 ▄████████▀                                     │
│   COMPLETE INSTALLER - Safe Gaming Optimizations                                               │
│                        ROG STRIX B550-XE │ Ryzen 7 5800X │ RTX 3060 12GB                       │
╰────────────────────────────────────────────────────────────────────────────────────────────────╯
EOF
echo -e "${NC}"

log "Starting complete installation with safe gaming optimizations..."

# ═══════════════════════════════════════════════════════════════════════════
#  🔍 CONFLICT DETECTION & PREVENTION
# ═══════════════════════════════════════════════════════════════════════════

gaming_info "Checking existing CachyOS gaming packages..."

# Check if cachyos-gaming-meta is already installed
if pacman -Q cachyos-gaming-meta &>/dev/null; then
    gaming_info "✓ cachyos-gaming-meta detected - skipping duplicate packages"
    CACHYOS_GAMING_INSTALLED=true
else
    CACHYOS_GAMING_INSTALLED=false
fi

# Check if cachyos-gaming-applications is already installed
if pacman -Q cachyos-gaming-applications &>/dev/null; then
    gaming_info "✓ cachyos-gaming-applications detected - skipping duplicate launchers"
    CACHYOS_APPS_INSTALLED=true
else
    CACHYOS_APPS_INSTALLED=false
fi

# Detect existing Wine installation
if pacman -Q wine-cachyos-opt &>/dev/null || pacman -Q wine-cachyos &>/dev/null; then
    gaming_info "✓ CachyOS Wine detected - will not install conflicting wine versions"
    CACHYOS_WINE_INSTALLED=true
else
    CACHYOS_WINE_INSTALLED=false
fi

# Detect existing Proton
if pacman -Q proton-cachyos-slr &>/dev/null || pacman -Q proton-cachyos &>/dev/null; then
    gaming_info "✓ CachyOS Proton detected - skipping redundant proton packages"
    CACHYOS_PROTON_INSTALLED=true
else
    CACHYOS_PROTON_INSTALLED=false
fi

# ═══════════════════════════════════════════════════════════════════════════
#  📦 BASE INSTALLATION (Original Script)
# ═══════════════════════════════════════════════════════════════════════════

# Install git
command -v git &>/dev/null || sudo pacman -S --needed --noconfirm git

log "Cloning needed repositories..."

# Clone repos
if [ -d "$INSTALL_DIR" ]; then
    cd "$INSTALL_DIR" && git pull --quiet || true
else
    git clone --depth 1 "$DOT_REPO_URL" "$INSTALL_DIR" || error "Clone dots failed"
    git clone --depth 1 "$WPP_REPO_URL" "$WPP_DIR" || error "Clone wallpapers failed"
    cd "$INSTALL_DIR"
fi

log "Updating system packages..."
sudo pacman -Syu --noconfirm
yay -Syu --noconfirm

log "Installing base dotfiles configuration..."
chmod +x install.sh
./install.sh --kitty --nvim --fastfetch --zathura --zshrc --aur-helper=paru

log "Installing essential desktop packages..."
sudo pacman -S --needed --noconfirm \
    nautilus gnome-disk-utility \
    wlr-randr kanshi stow wtype inotify-tools \
    cachyos-gaming-meta cachyos-gaming-applications \
    fcitx5 fcitx5-qt fcitx5-gtk fcitx5-configtool

yay -S --noconfirm --needed \
    nwg-displays fcitx5-bamboo-git \
    microsoft-edge-stable-bin github-desktop vesktop-bin

# ═══════════════════════════════════════════════════════════════════════════
#  🎮 SAFE GAMING OPTIMIZATIONS (No Conflicts)
# ═══════════════════════════════════════════════════════════════════════════

gaming_info "Starting safe gaming optimizations..."

# ─────────────────────────────────────────────────────────────────────────────
# 1. NVIDIA DRIVERS (CachyOS doesn't include these by default)
# ─────────────────────────────────────────────────────────────────────────────
gaming_info "Installing NVIDIA drivers..."
sudo pacman -S --needed --noconfirm \
    linux-headers linux-lts-headers

sudo pacman -S --needed --noconfirm \
    nvidia-dkms nvidia-utils lib32-nvidia-utils \
    nvidia-settings opencl-nvidia lib32-opencl-nvidia \
    libva-nvidia-driver

# Enable NVIDIA services
sudo systemctl enable nvidia-suspend.service
sudo systemctl enable nvidia-hibernate.service
sudo systemctl enable nvidia-resume.service

# ─────────────────────────────────────────────────────────────────────────────
# 2. ADDITIONAL TOOLS (Not included in cachyos-gaming-*)
# ─────────────────────────────────────────────────────────────────────────────
gaming_info "Installing additional gaming tools (not in CachyOS meta packages)..."

# These are NOT in cachyos-gaming-meta or cachyos-gaming-applications
ADDITIONAL_TOOLS=""

# Only install if not already present via cachyos packages
if [ "$CACHYOS_GAMING_INSTALLED" = false ]; then
    # Install gamemode if not present
    if ! pacman -Q gamemode &>/dev/null; then
        ADDITIONAL_TOOLS="$ADDITIONAL_TOOLS gamemode lib32-gamemode"
    fi
fi

# Install supplementary tools (safe, not in CachyOS meta)
yay -S --noconfirm --needed \
    bottles \
    protonup-qt \
    gwe \
    lib32-pipewire \
    obs-studio

# ─────────────────────────────────────────────────────────────────────────────
# 3. PERFORMANCE OPTIMIZATION TOOLS
# ─────────────────────────────────────────────────────────────────────────────
gaming_info "Installing performance monitoring tools..."

# CoreCtrl for AMD CPU/APU control (safe for Ryzen)
sudo pacman -S --needed --noconfirm corectrl

# Optional: Install ananicy-cpp for process priority management
yay -S --noconfirm --needed ananicy-cpp
sudo systemctl enable --now ananicy-cpp

# ─────────────────────────────────────────────────────────────────────────────
# 4. KERNEL PARAMETERS (Safe additions to GRUB)
# ─────────────────────────────────────────────────────────────────────────────
gaming_info "Configuring kernel parameters..."

GRUB_FILE="/etc/default/grub"
GRUB_MODIFIED=false

# Check and add NVIDIA parameters
if ! grep -q "nvidia_drm.modeset=1" "$GRUB_FILE"; then
    sudo sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="/GRUB_CMDLINE_LINUX_DEFAULT="nvidia_drm.modeset=1 nvidia.NVreg_PreserveVideoMemoryAllocations=1 /' "$GRUB_FILE"
    GRUB_MODIFIED=true
    gaming_info "Added NVIDIA kernel parameters"
fi

# Check and add AMD CPU parameters (if not present)
if ! grep -q "amd_pstate" "$GRUB_FILE"; then
    sudo sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="/GRUB_CMDLINE_LINUX_DEFAULT="amd_pstate=active /' "$GRUB_FILE"
    GRUB_MODIFIED=true
    gaming_info "Added AMD P-State driver parameter"
fi

# Optional: Performance mitigation (user choice)
echo ""
echo -e "${YELLOW}⚠️  PERFORMANCE vs SECURITY CHOICE:${NC}"
echo -e "Adding ${CYAN}mitigations=off${NC} can increase gaming performance by 5-10%"
echo -e "but reduces security against Spectre/Meltdown attacks."
echo ""
read -p "Add mitigations=off for better gaming performance? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    if ! grep -q "mitigations=off" "$GRUB_FILE"; then
        sudo sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="/GRUB_CMDLINE_LINUX_DEFAULT="mitigations=off /' "$GRUB_FILE"
        GRUB_MODIFIED=true
        gaming_info "Added mitigations=off for performance"
    fi
else
    gaming_info "Skipped mitigations=off (keeping system secure)"
fi

# Rebuild GRUB config if modified
if [ "$GRUB_MODIFIED" = true ]; then
    sudo grub-mkconfig -o /boot/grub/grub.cfg
    gaming_info "GRUB configuration updated"
fi

# ─────────────────────────────────────────────────────────────────────────────
# 5. SYSCTL OPTIMIZATIONS (Safe network & memory tuning)
# ─────────────────────────────────────────────────────────────────────────────
gaming_info "Configuring system parameters..."

sudo tee /etc/sysctl.d/99-gaming.conf > /dev/null << 'SYSCTL'
# Network optimizations for gaming
net.core.netdev_max_backlog = 16384
net.core.somaxconn = 8192
net.ipv4.tcp_fastopen = 3
net.ipv4.tcp_congestion_control = bbr

# Memory optimizations (32GB RAM)
vm.swappiness = 10
vm.vfs_cache_pressure = 50
vm.dirty_ratio = 10
vm.dirty_background_ratio = 5

# File system
fs.file-max = 2097152
fs.inotify.max_user_watches = 524288
SYSCTL

sudo sysctl -p /etc/sysctl.d/99-gaming.conf

# ─────────────────────────────────────────────────────────────────────────────
# 6. I/O SCHEDULER (Safe for all storage types)
# ─────────────────────────────────────────────────────────────────────────────
gaming_info "Optimizing I/O schedulers..."

sudo tee /etc/udev/rules.d/60-ioschedulers.rules > /dev/null << 'UDEV'
# NVMe: none scheduler for best performance
ACTION=="add|change", KERNEL=="nvme[0-9]n[0-9]", ATTR{queue/scheduler}="none"
# SSD: mq-deadline
ACTION=="add|change", KERNEL=="sd[a-z]", ATTR{queue/rotational}=="0", ATTR{queue/scheduler}="mq-deadline"
# HDD: bfq
ACTION=="add|change", KERNEL=="sd[a-z]", ATTR{queue/rotational}=="1", ATTR{queue/scheduler}="bfq"
UDEV

# ─────────────────────────────────────────────────────────────────────────────
# 7. NVIDIA MODULE CONFIGURATION (Wayland/Hyprland specific)
# ─────────────────────────────────────────────────────────────────────────────
gaming_info "Configuring NVIDIA modules for Hyprland..."

sudo tee /etc/modules-load.d/nvidia.conf > /dev/null << 'NVMODULES'
nvidia
nvidia_modeset
nvidia_uvm
nvidia_drm
NVMODULES

sudo tee /etc/modprobe.d/nvidia.conf > /dev/null << 'NVMODPROBE'
options nvidia_drm modeset=1
options nvidia NVreg_PreserveVideoMemoryAllocations=1
options nvidia NVreg_TemporaryFilePath=/var/tmp
NVMODPROBE

# ─────────────────────────────────────────────────────────────────────────────
# 8. HYPRLAND ENVIRONMENT (NVIDIA + Gaming specific)
# ─────────────────────────────────────────────────────────────────────────────
gaming_info "Creating Hyprland gaming environment configuration..."

mkdir -p ~/.config/hypr

cat > ~/.config/hypr/gaming-env.conf << 'HYPRENV'
# ═══════════════════════════════════════════════════════════════════════════
#  NVIDIA Configuration for Hyprland
# ═══════════════════════════════════════════════════════════════════════════
env = LIBVA_DRIVER_NAME,nvidia
env = XDG_SESSION_TYPE,wayland
env = GBM_BACKEND,nvidia-drm
env = __GLX_VENDOR_LIBRARY_NAME,nvidia
env = WLR_NO_HARDWARE_CURSORS,1

# VRR/G-SYNC Support
env = __GL_GSYNC_ALLOWED,1
env = __GL_VRR_ALLOWED,1

# ═══════════════════════════════════════════════════════════════════════════
#  Gaming Optimizations (works with CachyOS wine/proton)
# ═══════════════════════════════════════════════════════════════════════════
# NVIDIA features for Proton
env = PROTON_ENABLE_NVAPI,1
env = PROTON_ENABLE_NGX_UPDATER,1

# DXVK optimizations
env = DXVK_ASYNC,1

# AMD FSR upscaling support
env = WINE_FULLSCREEN_FSR,1

# MangoHud (if you want it always on)
# env = MANGOHUD,1
HYPRENV

# Add source to main Hyprland config if not already present
HYPR_CONF="$HOME/.config/hypr/hyprland.conf"
if [ -f "$HYPR_CONF" ]; then
    if ! grep -q "gaming-env.conf" "$HYPR_CONF"; then
        echo "source = ~/.config/hypr/gaming-env.conf" >> "$HYPR_CONF"
        gaming_info "Added gaming-env.conf to Hyprland config"
    else
        gaming_info "gaming-env.conf already sourced in Hyprland"
    fi
else
    warning "Hyprland config not found at $HYPR_CONF"
    gaming_info "You'll need to manually source gaming-env.conf"
fi

# ─────────────────────────────────────────────────────────────────────────────
# 9. MANGOHUD CONFIGURATION (Works with CachyOS version)
# ─────────────────────────────────────────────────────────────────────────────
gaming_info "Configuring MangoHud..."

mkdir -p ~/.config/MangoHud
cat > ~/.config/MangoHud/MangoHud.conf << 'MANGOHUD'
# Performance Display
fps
frametime=0
frame_timing=1
gpu_stats
gpu_temp
cpu_stats
cpu_temp
ram
vram

# Position & Style
position=top-left
font_size=24
background_alpha=0.4

# Controls
toggle_hud=Shift_R+F12
toggle_logging=Shift_L+F2

# Logging
log_duration=60
output_folder=/home/$USER/mangohud_logs
MANGOHUD

mkdir -p ~/mangohud_logs

# ─────────────────────────────────────────────────────────────────────────────
# 10. GAMEMODE CONFIGURATION (If installed)
# ─────────────────────────────────────────────────────────────────────────────
if command -v gamemoded &>/dev/null; then
    gaming_info "Configuring GameMode..."
    
    mkdir -p ~/.config
    cat > ~/.config/gamemode.ini << 'GAMEMODE'
[general]
renice=10

[gpu]
apply_gpu_optimisations=accept
gpu_device=0

[custom]
start=notify-send "GameMode Activated" "Performance mode enabled"
end=notify-send "GameMode Deactivated" "Normal mode restored"
GAMEMODE
else
    gaming_info "GameMode not detected (may be included in cachyos-gaming-meta)"
fi

# ─────────────────────────────────────────────────────────────────────────────
# 11. SYSTEM LIMITS
# ─────────────────────────────────────────────────────────────────────────────
gaming_info "Configuring system limits..."

sudo tee /etc/security/limits.d/99-gaming.conf > /dev/null << 'LIMITS'
* soft nofile 1048576
* hard nofile 1048576
LIMITS

# ─────────────────────────────────────────────────────────────────────────────
# 12. SHADER CACHE DIRECTORIES
# ─────────────────────────────────────────────────────────────────────────────
gaming_info "Setting up shader cache directories..."

mkdir -p ~/.cache/mesa_shader_cache
mkdir -p ~/.cache/nvidia/GLCache
mkdir -p ~/.local/share/Steam/steamapps/shadercache

# ─────────────────────────────────────────────────────────────────────────────
# 13. GAMING MODE TOGGLE SCRIPT
# ─────────────────────────────────────────────────────────────────────────────
gaming_info "Creating gaming mode toggle script..."

sudo tee /usr/local/bin/gaming-mode > /dev/null << 'GAMESCRIPT'
#!/bin/bash

if [ "$1" == "on" ]; then
    echo "🎮 Activating Gaming Mode..."
    
    # Set CPU governor to performance
    if [ -f /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor ]; then
        echo performance | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor > /dev/null
        echo "✓ CPU governor: performance"
    fi
    
    # Stop non-essential services
    sudo systemctl stop bluetooth.service 2>/dev/null && echo "✓ Bluetooth stopped"
    
    # Clear system cache
    sync && echo 3 | sudo tee /proc/sys/vm/drop_caches > /dev/null
    echo "✓ System cache cleared"
    
    notify-send "Gaming Mode" "Performance optimizations activated" -u normal
    
elif [ "$1" == "off" ]; then
    echo "🔧 Deactivating Gaming Mode..."
    
    # Set CPU governor back to schedutil
    if [ -f /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor ]; then
        echo schedutil | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor > /dev/null
        echo "✓ CPU governor: schedutil"
    fi
    
    # Restart services
    sudo systemctl start bluetooth.service 2>/dev/null && echo "✓ Bluetooth started"
    
    notify-send "Gaming Mode" "Normal mode restored" -u normal
else
    echo "Usage: gaming-mode [on|off]"
    echo ""
    echo "Examples:"
    echo "  gaming-mode on   - Enable performance mode"
    echo "  gaming-mode off  - Return to normal mode"
fi
GAMESCRIPT

sudo chmod +x /usr/local/bin/gaming-mode

# ─────────────────────────────────────────────────────────────────────────────
# 14. STEAM LAUNCH OPTIONS GUIDE
# ─────────────────────────────────────────────────────────────────────────────
gaming_info "Creating Steam launch options guide..."

cat > ~/steam-launch-options.txt << 'STEAM'
═══════════════════════════════════════════════════════════════════════════
  STEAM LAUNCH OPTIONS GUIDE
  Compatible with CachyOS Wine/Proton
═══════════════════════════════════════════════════════════════════════════

BASIC TEMPLATES:
───────────────

Native Linux games:
    mangohud %command%

Proton games (Windows):
    PROTON_ENABLE_NVAPI=1 DXVK_ASYNC=1 mangohud %command%

With GameMode:
    gamemoderun mangohud %command%


HIGH REFRESH RATE:
──────────────────

For 144Hz+ monitors:
    DXVK_FRAME_RATE=144 mangohud %command%

Unlimited FPS:
    DXVK_FRAME_RATE=0 mangohud %command%


FSR UPSCALING:
──────────────

Enable FSR with strength (0-5, lower = sharper):
    WINE_FULLSCREEN_FSR=1 WINE_FULLSCREEN_FSR_STRENGTH=2 mangohud %command%


COMBINED (Recommended):
───────────────────────

Full optimization:
    PROTON_ENABLE_NVAPI=1 DXVK_ASYNC=1 gamemoderun mangohud %command%

With FSR:
    WINE_FULLSCREEN_FSR=1 PROTON_ENABLE_NVAPI=1 DXVK_ASYNC=1 gamemoderun mangohud %command%


NOTES:
──────
- CachyOS already uses optimized Wine/Proton versions
- No need to force wine-staging or other wine versions
- GameMode works automatically with CachyOS gaming packages
- MangoHud toggle in-game: Shift+F12

═══════════════════════════════════════════════════════════════════════════
STEAM

# ═══════════════════════════════════════════════════════════════════════════
#  📊 INSTALLATION SUMMARY
# ═══════════════════════════════════════════════════════════════════════════

log "Installation completed successfully!"
echo ""
gaming_info "═══════════════════════════════════════════════════════════════"
gaming_info "  ✅ SAFE GAMING OPTIMIZATIONS APPLIED"
gaming_info "═══════════════════════════════════════════════════════════════"
echo ""
echo -e "${GREEN}Installed/Configured:${NC}"
echo ""
echo -e "  ${GREEN}✓${NC} NVIDIA drivers with Wayland/Hyprland support"
echo -e "  ${GREEN}✓${NC} CachyOS gaming packages (preserved existing)"
echo -e "  ${GREEN}✓${NC} Additional tools: Bottles, ProtonUp-Qt, GWE, OBS"
echo -e "  ${GREEN}✓${NC} Performance optimizations: sysctl, I/O schedulers"
echo -e "  ${GREEN}✓${NC} MangoHud & GameMode configurations"
echo -e "  ${GREEN}✓${NC} Hyprland gaming environment variables"
echo -e "  ${GREEN}✓${NC} Gaming mode toggle script"
echo ""
echo -e "${CYAN}What was SKIPPED (to avoid conflicts):${NC}"
echo ""
if [ "$CACHYOS_GAMING_INSTALLED" = true ]; then
    echo -e "  ${YELLOW}⊘${NC} Duplicate gaming libraries (already in cachyos-gaming-meta)"
fi
if [ "$CACHYOS_APPS_INSTALLED" = true ]; then
    echo -e "  ${YELLOW}⊘${NC} Duplicate launchers (already in cachyos-gaming-applications)"
fi
if [ "$CACHYOS_WINE_INSTALLED" = true ]; then
    echo -e "  ${YELLOW}⊘${NC} Alternative Wine versions (using CachyOS optimized Wine)"
fi
if [ "$CACHYOS_PROTON_INSTALLED" = true ]; then
    echo -e "  ${YELLOW}⊘${NC} Alternative Proton versions (using CachyOS Proton)"
fi
echo ""
echo -e "${YELLOW}📝 IMPORTANT NEXT STEPS:${NC}"
echo ""
echo -e "  1. ${CYAN}REBOOT REQUIRED${NC} for all changes to take effect"
echo -e "  2. After reboot, enable gaming mode: ${CYAN}gaming-mode on${NC}"
echo -e "  3. Configure CoreCtrl for GPU management"
echo -e "  4. Test MangoHud: ${CYAN}mangohud glxgears${NC}"
echo -e "  5. Steam launch options saved to: ${CYAN}~/steam-launch-options.txt${NC}"
echo -e "  6. Install Proton-GE via: ${CYAN}protonup-qt${NC}"
echo ""
echo -e "${YELLOW}🎯 USEFUL COMMANDS:${NC}"
echo ""
echo -e "  ${CYAN}gaming-mode on/off${NC}     - Toggle performance mode"
echo -e "  ${CYAN}nvidia-smi${NC}             - Check GPU status"
echo -e "  ${CYAN}corectrl${NC}               - Open GPU control panel"
echo -e "  ${CYAN}mangohud glxgears${NC}      - Test overlay"
echo ""
gaming_info "═══════════════════════════════════════════════════════════════"
echo ""
log "Log file saved to: $LOG_FILE"
echo ""

# Prompt for reboot
read -p "Do you want to reboot now to apply all changes? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    log "Rebooting system..."
    sudo reboot
else
    warning "Please reboot your system manually to apply all changes."
    echo -e "${YELLOW}Run:${NC} ${CYAN}sudo reboot${NC}"
fi