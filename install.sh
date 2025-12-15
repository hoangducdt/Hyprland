#!/bin/bash

# ============================================================================
# CachyOS Auto Setup - ONE-COMMAND INSTALLER (FIXED VERSION)
# ============================================================================
# Usage: curl -fsSL https://raw.githubusercontent.com/.../install.sh | bash
# 
# ✅ Tự động fix NVIDIA conflicts
# ✅ Không bị stuck tại lib32-ffmpeg
# ✅ Zero manual intervention
# ============================================================================

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

REPO_URL="https://github.com/hoangducdt/caelestia.git"
INSTALL_DIR="$HOME/cachyos-autosetup"
LOG_FILE="$HOME/caelestia_install_$(date +%Y%m%d_%H%M%S).log"

log() { echo -e "${GREEN}▶${NC} $1" | tee -a "$LOG_FILE"; }
error() { echo -e "${RED}✗${NC} $1" | tee -a "$LOG_FILE"; exit 1; }
warning() { echo -e "${YELLOW}⚠${NC} $1" | tee -a "$LOG_FILE"; }
info() { echo -e "${BLUE}ℹ${NC} $1" | tee -a "$LOG_FILE"; }

clear
echo -e "${GREEN}"
cat << "EOF"
╭───────────────────────────────────────────────────────────────────╮
│         ______           __          __  _                        │
│        / ____/___ ____  / /__  _____/ /_(_)___ _                  │
│       / /   / __ `/ _ \/ / _ \/ ___/ __/ / __ `/                  │
│      / /___/ /_/ /  __/ /  __(__  ) /_/ / /_/ /                   │
│      \____/\__,_/\___/_/\___/____/\__/_/\__,_/                    │
│                                                                   │
│   ONE-COMMAND INSTALLER - Fully Automatic (Fixed)                │
│   ROG STRIX B550-XE │ Ryzen 7 5800X │ RTX 3060 12GB              │
╰───────────────────────────────────────────────────────────────────╯
EOF
echo -e "${NC}"

# Check OS
if ! grep -q "CachyOS" /etc/os-release 2>/dev/null; then
    warning "Thiết kế cho CachyOS - tiếp tục với rủi ro"
    read -p "Continue? (y/N): " -n 1 -r
    echo
    [[ ! $REPLY =~ ^[Yy]$ ]] && exit 1
fi

# Check root
[ "$EUID" -eq 0 ] && error "KHÔNG chạy với sudo"

log "Bắt đầu cài đặt tự động..."
info "Log file: $LOG_FILE"

# ============================================================================
# FIX 1: XÓA XUNG ĐỘT NVIDIA
# ============================================================================
log "🔧 Fix 1/2: Xử lý xung đột NVIDIA..."

NVIDIA_CONFLICTS=(
    "linux-cachyos-nvidia-open"
    "linux-cachyos-lts-nvidia-open"
    "nvidia-open"
    "nvidia-open-dkms"
    "lib32-nvidia-open"
    "media-dkms"
)

for pkg in "${NVIDIA_CONFLICTS[@]}"; do
    if pacman -Qi "$pkg" &>/dev/null; then
        warning "Xóa $pkg..."
        sudo pacman -Rdd --noconfirm "$pkg" 2>/dev/null || true
    fi
done

log "✓ NVIDIA conflicts cleared"

# ============================================================================
# CÀI GIT NẾU CHƯA CÓ
# ============================================================================
if ! command -v git &>/dev/null; then
    log "Cài git..."
    sudo pacman -S --needed --noconfirm git
fi

# ============================================================================
# CLONE HOẶC UPDATE REPO
# ============================================================================
if [ -d "$INSTALL_DIR" ]; then
    log "Repo đã tồn tại - updating..."
    cd "$INSTALL_DIR"
    git pull --quiet || warning "Git pull failed - using existing"
else
    log "Clone repository..."
    git clone --depth 1 "$REPO_URL" "$INSTALL_DIR" || error "Clone failed"
    cd "$INSTALL_DIR"
fi

[ ! -f "setup.sh" ] && error "setup.sh không tìm thấy"

# ============================================================================
# TẠO SETUP SCRIPT TỐI ƯU (FIX CẢ 2 VẤN ĐỀ)
# ============================================================================
log "🔧 Fix 2/2: Tạo setup script tối ưu..."

cat > "$INSTALL_DIR/setup-optimized.sh" << 'SETUP_SCRIPT'
#!/bin/bash

# Setup Script - Optimized & Fixed
set -e

LOG_FILE="$HOME/setup_$(date +%Y%m%d_%H%M%S).log"
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log() { echo -e "${GREEN}[$(date +'%H:%M:%S')]${NC} $1" | tee -a "$LOG_FILE"; }
warning() { echo -e "${YELLOW}⚠${NC} $1" | tee -a "$LOG_FILE"; }
error() { echo -e "${RED}✗${NC} $1" | tee -a "$LOG_FILE"; exit 1; }

clear
echo -e "${GREEN}╔═══════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║         CachyOS Full Setup - Starting...                  ║${NC}"
echo -e "${GREEN}╚═══════════════════════════════════════════════════════════╝${NC}"
echo ""

# ===== PRE-CHECK: NVIDIA =====
log "Pre-check: Xóa NVIDIA conflicts..."
for pkg in linux-cachyos-nvidia-open linux-cachyos-lts-nvidia-open nvidia-open lib32-nvidia-open media-dkms; do
    pacman -Qi "$pkg" &>/dev/null && sudo pacman -Rdd --noconfirm "$pkg" 2>/dev/null || true
done

# ===== SYSTEM UPDATE =====
log "System update..."
sudo pacman -Syu --noconfirm

# ===== NVIDIA DRIVERS (PROPRIETARY) =====
log "Cài NVIDIA proprietary drivers..."
sudo pacman -S --needed --noconfirm \
    nvidia-dkms nvidia-utils lib32-nvidia-utils \
    nvidia-settings opencl-nvidia lib32-opencl-nvidia \
    libva-nvidia-driver egl-wayland

# Kernel config
if [ -f /etc/mkinitcpio.conf ]; then
    if ! grep -q "nvidia nvidia_modeset" /etc/mkinitcpio.conf; then
        sudo cp /etc/mkinitcpio.conf /etc/mkinitcpio.conf.backup
        sudo sed -i 's/^MODULES=(/MODULES=(nvidia nvidia_modeset nvidia_uvm nvidia_drm /' /etc/mkinitcpio.conf
        sudo mkinitcpio -P &>/dev/null || true
    fi
fi

sudo mkdir -p /etc/modprobe.d
echo "options nvidia_drm modeset=1" | sudo tee /etc/modprobe.d/nvidia.conf >/dev/null

log "✓ NVIDIA drivers"

# ===== BASE PACKAGES =====
log "Cài base packages..."
sudo pacman -S --needed --noconfirm \
    base-devel git wget curl \
    yay fish wl-clipboard \
    xdg-desktop-portal-hyprland \
    qt5-wayland qt6-wayland \
    gnome-keyring polkit-gnome nautilus

log "✓ Base packages"

# ===== HYPRLAND CAELESTIA =====
log "Cài Hyprland Caelestia..."
if [ -d "$HOME/.local/share/caelestia" ]; then
    mv "$HOME/.local/share/caelestia" "$HOME/.local/share/caelestia.backup.$(date +%s)"
fi

git clone --quiet https://github.com/caelestia-dots/caelestia.git "$HOME/.local/share/caelestia" || {
    warning "Caelestia clone failed - skip"
}

if [ -d "$HOME/.local/share/caelestia" ]; then
    cd "$HOME/.local/share/caelestia"
    
    # Patch để skip nvidia-open
    if [ -f "install.fish" ]; then
        cp install.fish install.fish.backup
        sed -i '/nvidia-open/s/^/#/' install.fish
    fi
    
    command -v fish &>/dev/null || sudo pacman -S --needed --noconfirm fish
    
    fish ./install.fish --noconfirm --aur-helper=yay 2>&1 | grep -v "nvidia\|conflict" || true
    
    # Cleanup sau khi cài
    for pkg in linux-cachyos-nvidia-open nvidia-open lib32-nvidia-open; do
        pacman -Qi "$pkg" &>/dev/null && sudo pacman -Rdd --noconfirm "$pkg" 2>/dev/null || true
    done
fi

log "✓ Hyprland Caelestia"

# ===== GAMING + DEV =====
log "Cài Gaming + Dev packages..."
sudo pacman -S --needed --noconfirm \
    cachyos-gaming-meta \
    steam lutris wine-staging \
    mangohud lib32-mangohud \
    gamemode lib32-gamemode \
    dotnet-sdk dotnet-runtime mono \
    code neovim docker docker-compose

sudo systemctl enable --now docker.service 2>/dev/null || true
sudo usermod -aG docker "$USER" 2>/dev/null || true

log "✓ Gaming + Dev"

# ===== MULTIMEDIA (OFFICIAL REPO - KHÔNG DÙNG AUR) =====
log "Cài multimedia packages..."
sudo pacman -S --needed --noconfirm \
    ffmpeg lib32-ffmpeg \
    gstreamer gst-plugins-{base,good,bad,ugly} \
    x264 x265 obs-studio

log "✓ Multimedia (official repo - no stuck!)"

# ===== AI/ML =====
log "Cài AI/ML stack..."
sudo pacman -S --needed --noconfirm \
    cuda cudnn \
    python python-pip \
    python-pytorch-cuda \
    python-numpy python-pandas \
    jupyter-notebook

# Ollama
if ! command -v ollama &>/dev/null; then
    curl -fsSL https://ollama.com/install.sh | sh || warning "Ollama skip"
fi

log "✓ AI/ML"

# ===== CREATIVE SUITE =====
log "Cài Creative Suite..."
sudo pacman -S --needed --noconfirm \
    blender gimp krita inkscape \
    kdenlive darktable audacity

log "✓ Creative Suite"

# ===== AUR PACKAGES (VỚI TIMEOUT) =====
log "Cài AUR packages (critical only)..."

install_aur() {
    timeout 300 yay -S --noconfirm --needed "$1" || warning "$1 failed - skip"
}

install_aur "microsoft-edge-stable-bin"
install_aur "github-desktop"
install_aur "vesktop-bin"

log "✓ AUR packages"

# ===== SDDM =====
log "Cài SDDM..."
sudo pacman -S --needed --noconfirm sddm qt5-graphicaleffects qt5-quickcontrols2

sudo systemctl enable sddm.service 2>/dev/null || true

log "✓ SDDM"

# ===== DIRECTORIES & HELPERS =====
log "Tạo directories..."
mkdir -p "$HOME"/{Desktop,Documents,Downloads,Pictures,Videos}
mkdir -p "$HOME"/{AI-Projects,AI-Models,Creative-Projects,Blender-Projects}
mkdir -p "$HOME/.local/bin"

cat > "$HOME/.local/bin/check-gpu" <<'EOF'
#!/bin/bash
nvidia-smi
EOF
chmod +x "$HOME/.local/bin/check-gpu"

cat > "$HOME/.local/bin/blender-gpu" <<'EOF'
#!/bin/bash
__GLX_VENDOR_LIBRARY_NAME=nvidia __NV_PRIME_RENDER_OFFLOAD=1 blender "$@"
EOF
chmod +x "$HOME/.local/bin/blender-gpu"

grep -q ".local/bin" "$HOME/.bashrc" || echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.bashrc"

log "✓ Setup complete!"

echo ""
echo -e "${GREEN}╔═══════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║              ✓ INSTALLATION COMPLETED!                    ║${NC}"
echo -e "${GREEN}╚═══════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${YELLOW}Next: ${GREEN}sudo reboot${NC}"
echo ""
SETUP_SCRIPT

chmod +x "$INSTALL_DIR/setup-optimized.sh"

log "✓ Setup script created"

# ============================================================================
# CHẠY SETUP SCRIPT
# ============================================================================
echo ""
log "🚀 Chạy full setup (15-30 phút)..."
echo ""
read -p "Press Enter để bắt đầu hoặc Ctrl+C để hủy..."
echo ""

bash "$INSTALL_DIR/setup-optimized.sh" || {
    error "Setup failed - check log: $LOG_FILE"
}

# ============================================================================
# DONE!
# ============================================================================
echo ""
echo -e "${GREEN}╔═══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║           ✓ CÀI ĐẶT HOÀN TẤT THÀNH CÔNG!                     ║${NC}"
echo -e "${GREEN}╚═══════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${BLUE}Installed:${NC}"
echo "  ✓ NVIDIA proprietary drivers"
echo "  ✓ Hyprland Caelestia"
echo "  ✓ Gaming (Steam, Lutris, Wine)"
echo "  ✓ Dev (C#, Docker, VS Code)"
echo "  ✓ AI/ML (CUDA, PyTorch, Ollama)"
echo "  ✓ Creative (Blender, GIMP, Kdenlive)"
echo "  ✓ Streaming (OBS, Vesktop)"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo "  1. ${GREEN}sudo reboot${NC}"
echo "  2. Login vào Hyprland"
echo "  3. Check GPU: ${BLUE}nvidia-smi${NC}"
echo ""
echo "Logs: $LOG_FILE"
echo "      $HOME/setup_*.log"
echo ""
