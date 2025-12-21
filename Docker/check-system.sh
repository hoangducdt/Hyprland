#!/bin/bash

# Caelestia System Check Script
# Kiểm tra yêu cầu hệ thống trước khi deploy

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║        Caelestia System Requirements Check                ║${NC}"
echo -e "${BLUE}║        CachyOS + RTX 3060 Edition                         ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""

passed=0
failed=0
warnings=0

check_pass() {
    echo -e "${GREEN}✓${NC} $1"
    ((passed++))
}

check_fail() {
    echo -e "${RED}✗${NC} $1"
    ((failed++))
}

check_warn() {
    echo -e "${YELLOW}⚠${NC} $1"
    ((warnings++))
}

section() {
    echo ""
    echo -e "${BLUE}=== $1 ===${NC}"
}

# ==================== OS CHECK ====================
section "Operating System"

if [ -f /etc/os-release ]; then
    . /etc/os-release
    echo "Distribution: $NAME"
    echo "Version: $VERSION"
    
    if [[ "$ID" == "cachyos" ]] || [[ "$ID_LIKE" == *"arch"* ]]; then
        check_pass "CachyOS/Arch-based detected"
    else
        check_warn "Not CachyOS, but might work on other distributions"
    fi
else
    check_fail "Cannot detect OS"
fi

# ==================== CPU CHECK ====================
section "CPU"

cpu_model=$(lscpu | grep "Model name" | cut -d ":" -f2 | xargs)
cpu_cores=$(nproc)
echo "CPU: $cpu_model"
echo "Cores: $cpu_cores"

if [ "$cpu_cores" -ge 8 ]; then
    check_pass "8+ CPU cores available"
elif [ "$cpu_cores" -ge 4 ]; then
    check_warn "4-7 cores detected. 8+ recommended for optimal performance"
else
    check_fail "Less than 4 cores. Minimum 4 cores required"
fi

# ==================== MEMORY CHECK ====================
section "Memory"

total_ram=$(free -g | awk '/^Mem:/{print $2}')
echo "Total RAM: ${total_ram}GB"

if [ "$total_ram" -ge 32 ]; then
    check_pass "32GB+ RAM available"
elif [ "$total_ram" -ge 16 ]; then
    check_warn "16-31GB RAM. 32GB recommended for SDXL"
else
    check_fail "Less than 16GB RAM. Minimum 16GB required"
fi

# ==================== GPU CHECK ====================
section "GPU"

if command -v nvidia-smi &> /dev/null; then
    check_pass "nvidia-smi found"
    
    gpu_name=$(nvidia-smi --query-gpu=name --format=csv,noheader)
    gpu_vram=$(nvidia-smi --query-gpu=memory.total --format=csv,noheader | cut -d " " -f1)
    driver_version=$(nvidia-smi --query-gpu=driver_version --format=csv,noheader)
    
    echo "GPU: $gpu_name"
    echo "VRAM: ${gpu_vram}MB"
    echo "Driver: $driver_version"
    
    if [ "$gpu_vram" -ge 12000 ]; then
        check_pass "12GB+ VRAM (can run SDXL)"
    elif [ "$gpu_vram" -ge 8000 ]; then
        check_warn "8-11GB VRAM (SD 1.5 OK, SDXL may struggle)"
    elif [ "$gpu_vram" -ge 6000 ]; then
        check_warn "6-7GB VRAM (SD 1.5 only)"
    else
        check_fail "Less than 6GB VRAM (insufficient for Stable Diffusion)"
    fi
else
    check_fail "nvidia-smi not found. NVIDIA drivers not installed?"
fi

# ==================== DOCKER CHECK ====================
section "Docker Desktop"

if command -v docker &> /dev/null; then
    check_pass "Docker installed"
    docker_version=$(docker --version)
    echo "$docker_version"
    
    # Check if Docker daemon is running
    if docker info &> /dev/null; then
        check_pass "Docker Desktop is running"
    else
        check_fail "Docker Desktop is not running"
        echo "Start Docker Desktop from Applications menu"
    fi
    
    # Docker Desktop doesn't require docker group membership
    check_pass "Using Docker Desktop (no group membership needed)"
else
    check_fail "Docker not found"
    echo "Install Docker Desktop for Linux"
fi

if docker compose version &> /dev/null; then
    compose_version=$(docker compose version)
    check_pass "Docker Compose available"
    echo "$compose_version"
else
    check_fail "Docker Compose not available"
fi

# ==================== NVIDIA CONTAINER TOOLKIT CHECK ====================
section "NVIDIA Container Toolkit"

if docker run --rm --gpus all nvidia/cuda:12.2.0-base-ubuntu22.04 nvidia-smi &> /dev/null; then
    check_pass "nvidia-container-toolkit working"
else
    check_fail "nvidia-container-toolkit not working"
    echo "Install: sudo pacman -S nvidia-container-toolkit"
    echo "Then: sudo systemctl restart docker"
fi

# ==================== STORAGE CHECK ====================
section "Storage"

df_output=$(df -h / | tail -1)
available=$(echo "$df_output" | awk '{print $4}')
echo "Root partition available: $available"

# Extract numeric value (remove G/T suffix)
available_num=$(echo "$available" | sed 's/[^0-9.]//g')
available_unit=$(echo "$available" | sed 's/[0-9.]//g')

if [[ "$available_unit" == "T" ]] || [[ "$available_num" -gt 200 ]]; then
    check_pass "200GB+ available storage"
elif [[ "$available_num" -gt 100 ]]; then
    check_warn "100-200GB available. More space recommended for models"
else
    check_fail "Less than 100GB available. Minimum 100GB required"
fi

# ==================== NETWORK CHECK ====================
section "Network"

if ping -c 1 8.8.8.8 &> /dev/null; then
    check_pass "Internet connection available"
else
    check_warn "Cannot reach internet (needed for downloads)"
fi

if ping -c 1 huggingface.co &> /dev/null; then
    check_pass "Can reach Hugging Face (for model downloads)"
else
    check_warn "Cannot reach Hugging Face"
fi

# ==================== CONFIGURATION FILES CHECK ====================
section "Configuration Files"

if [ -f "docker-compose.yml" ]; then
    check_pass "docker-compose.yml found"
else
    check_fail "docker-compose.yml not found"
fi

if [ -f ".env" ]; then
    check_pass ".env file found"
    
    # Check if passwords are set
    if grep -q "POSTGRES_PASSWORD=$" .env; then
        check_warn "Passwords not set in .env"
    else
        check_pass "Passwords appear to be set"
    fi
    
    # Check permissions
    perms=$(stat -c "%a" .env)
    if [ "$perms" == "600" ]; then
        check_pass ".env has correct permissions (600)"
    else
        check_warn ".env permissions are $perms, should be 600"
        echo "Run: chmod 600 .env"
    fi
else
    check_warn ".env file not found"
    echo "Copy _env to .env and configure it"
fi

# ==================== SUMMARY ====================
section "Summary"

echo ""
echo -e "Passed:   ${GREEN}$passed${NC}"
echo -e "Warnings: ${YELLOW}$warnings${NC}"
echo -e "Failed:   ${RED}$failed${NC}"
echo ""

if [ $failed -eq 0 ] && [ $warnings -eq 0 ]; then
    echo -e "${GREEN}✓ System is ready for deployment!${NC}"
    echo ""
    echo "Next steps:"
    echo "1. Review and edit .env file"
    echo "2. Create directories: mkdir -p ./sd-models ./sd-outputs"
    echo "3. Start services: docker compose up -d"
    exit 0
elif [ $failed -eq 0 ]; then
    echo -e "${YELLOW}⚠ System is mostly ready, but has warnings${NC}"
    echo "Review warnings above before deploying"
    exit 0
else
    echo -e "${RED}✗ System is not ready for deployment${NC}"
    echo "Fix failed checks above before proceeding"
    exit 1
fi
