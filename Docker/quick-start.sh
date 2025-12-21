#!/bin/bash

# Caelestia Quick Start Script
# Easy deployment for CachyOS + RTX 3060

set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}"
cat << "EOF"
╔════════════════════════════════════════════════════════════╗
║              Caelestia Quick Start                         ║
║        CachyOS + Docker Desktop + Stable Diffusion        ║
╚════════════════════════════════════════════════════════════╝
EOF
echo -e "${NC}"

# Function to print step
step() {
    echo ""
    echo -e "${GREEN}>>> $1${NC}"
    echo ""
}

# Check if Docker Desktop is running
if ! docker info &> /dev/null; then
    echo -e "${RED}Docker Desktop is not running!${NC}"
    echo "Please start Docker Desktop and try again."
    exit 1
fi

# Check if running as root
if [ "$EUID" -eq 0 ]; then
    echo -e "${RED}Don't run this script as root!${NC}"
    exit 1
fi

# Step 1: Check prerequisites
step "Step 1: Checking system requirements"

if [ -f "./check-system.sh" ]; then
    bash ./check-system.sh
    if [ $? -ne 0 ]; then
        echo -e "${RED}System check failed. Please fix the issues above.${NC}"
        exit 1
    fi
else
    echo -e "${YELLOW}check-system.sh not found, skipping checks${NC}"
fi

# Step 2: Setup .env file
step "Step 2: Setting up environment file"

if [ ! -f ".env" ]; then
    if [ -f "_env" ]; then
        echo "Copying _env to .env..."
        cp _env .env
        chmod 600 .env
        
        echo "Generating random passwords..."
        
        # Generate passwords
        POSTGRES_PW=$(openssl rand -base64 32 | tr -d '\n')
        REDIS_PW=$(openssl rand -base64 32 | tr -d '\n')
        NPM_DB_PW=$(openssl rand -base64 32 | tr -d '\n')
        MYSQL_ROOT_PW=$(openssl rand -base64 32 | tr -d '\n')
        ADMIN_PW=$(openssl rand -base64 24 | tr -d '\n')
        PAPERLESS_KEY=$(openssl rand -base64 32 | tr -d '\n')
        WEBUI_KEY=$(openssl rand -base64 32 | tr -d '\n')
        
        # Update .env file
        sed -i "s|^POSTGRES_PASSWORD=.*|POSTGRES_PASSWORD=$POSTGRES_PW|" .env
        sed -i "s|^REDIS_PASSWORD=.*|REDIS_PASSWORD=$REDIS_PW|" .env
        sed -i "s|^NPM_DB_PASSWORD=.*|NPM_DB_PASSWORD=$NPM_DB_PW|" .env
        sed -i "s|^MYSQL_ROOT_PASSWORD=.*|MYSQL_ROOT_PASSWORD=$MYSQL_ROOT_PW|" .env
        sed -i "s|^ADMIN_PASSWORD=.*|ADMIN_PASSWORD=$ADMIN_PW|" .env
        sed -i "s|^PAPERLESS_SECRET_KEY=.*|PAPERLESS_SECRET_KEY=$PAPERLESS_KEY|" .env
        sed -i "s|^WEBUI_SECRET_KEY=.*|WEBUI_SECRET_KEY=$WEBUI_KEY|" .env
        
        echo -e "${GREEN}✓ .env created with random passwords${NC}"
        echo ""
        echo -e "${YELLOW}IMPORTANT: Save this admin password:${NC}"
        echo -e "Admin Password: ${GREEN}$ADMIN_PW${NC}"
        echo ""
        read -p "Press Enter to continue..."
    else
        echo -e "${RED}_env file not found!${NC}"
        exit 1
    fi
else
    echo -e "${GREEN}✓ .env already exists${NC}"
fi

# Step 3: Create directories
step "Step 3: Creating directories"

echo "Creating Stable Diffusion directories..."
mkdir -p ./sd-models/Stable-diffusion
mkdir -p ./sd-models/Lora
mkdir -p ./sd-models/VAE
mkdir -p ./sd-models/embeddings
mkdir -p ./sd-outputs

echo "Creating other directories..."
mkdir -p ./init-scripts/postgres

echo "Setting permissions..."
chmod -R 755 ./sd-models
chmod -R 755 ./sd-outputs

echo -e "${GREEN}✓ Directories created${NC}"

# Step 4: Pull images
step "Step 4: Pulling Docker images (this may take a while)"

echo "Pulling images..."
if docker compose pull; then
    echo -e "${GREEN}✓ Images pulled successfully${NC}"
else
    echo -e "${RED}Failed to pull images${NC}"
    exit 1
fi

# Step 5: Start databases first
step "Step 5: Starting database services"

echo "Starting PostgreSQL, Redis, and MariaDB..."
docker compose up -d postgres redis npm-db

echo "Waiting 30 seconds for databases to initialize..."
sleep 30

if docker compose ps postgres redis npm-db | grep -q "running"; then
    echo -e "${GREEN}✓ Databases started${NC}"
else
    echo -e "${RED}Failed to start databases${NC}"
    echo "Check logs: docker compose logs postgres redis npm-db"
    exit 1
fi

# Step 6: Start remaining services
step "Step 6: Starting all other services"

echo "Starting remaining services..."
if docker compose up -d; then
    echo -e "${GREEN}✓ All services started${NC}"
else
    echo -e "${RED}Some services failed to start${NC}"
    echo "Check logs: docker compose logs"
fi

# Step 7: Wait for services
step "Step 7: Waiting for services to be healthy"

echo "Waiting for services to become healthy (max 3 minutes)..."
timeout=180
elapsed=0

while [ $elapsed -lt $timeout ]; do
    unhealthy=$(docker compose ps | grep -c "unhealthy" || true)
    starting=$(docker compose ps | grep -c "starting" || true)
    
    if [ $unhealthy -eq 0 ] && [ $starting -eq 0 ]; then
        echo -e "${GREEN}✓ All services are healthy${NC}"
        break
    fi
    
    echo -n "."
    sleep 5
    elapsed=$((elapsed + 5))
done

echo ""

# Step 8: Show summary
step "Installation Complete!"

echo -e "${GREEN}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║              🎉 Caelestia is ready!                       ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo "Access your services:"
echo ""
echo -e "${BLUE}Core Services:${NC}"
echo "  • Nginx Proxy Manager: http://localhost:81"
echo "    - Default: admin@example.com / changeme"
echo "    - ${YELLOW}CHANGE PASSWORD IMMEDIATELY!${NC}"
echo ""
echo -e "${BLUE}AI & Stable Diffusion:${NC}"
echo "  • Stable Diffusion WebUI: http://localhost:7860"
echo "  • ComfyUI: http://localhost:8188"
echo "  • Open WebUI: http://localhost:8080"
echo ""
echo -e "${BLUE}Other Services:${NC}"
echo "  • n8n Automation: Configure via Nginx Proxy Manager"
echo "  • Paperless-ngx: Configure via Nginx Proxy Manager"
echo "  • FileBrowser: Configure via Nginx Proxy Manager"
echo ""
echo -e "${BLUE}Quick Commands:${NC}"
echo "  • Check status: docker compose ps"
echo "  • View logs: docker compose logs -f"
echo "  • View SD logs: docker compose logs -f stable-diffusion-webui"
echo "  • Stop all: docker compose stop"
echo "  • Restart: docker compose restart"
echo ""
echo -e "${YELLOW}Next Steps:${NC}"
echo "  1. Change Nginx Proxy Manager password"
echo "  2. Download Stable Diffusion models (optional)"
echo "  3. Configure Nginx Proxy Manager for your domain"
echo "  4. Set up SSL certificates"
echo ""
echo -e "${YELLOW}Stable Diffusion Models:${NC}"
echo "  • Download to: ./sd-models/Stable-diffusion/"
echo "  • SD 1.5: https://huggingface.co/runwayml/stable-diffusion-v1-5"
echo "  • SDXL: https://huggingface.co/stabilityai/stable-diffusion-xl-base-1.0"
echo "  • Or browse: https://civitai.com/"
echo ""
echo -e "${GREEN}For detailed documentation, see README.md${NC}"
echo ""

# Offer to download SD model
echo ""
read -p "Would you like to download SD 1.5 model now? (4GB) [y/N]: " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    step "Downloading Stable Diffusion 1.5"
    cd ./sd-models/Stable-diffusion
    wget -O v1-5-pruned-emaonly.safetensors \
        "https://huggingface.co/runwayml/stable-diffusion-v1-5/resolve/main/v1-5-pruned-emaonly.safetensors"
    cd ../..
    echo -e "${GREEN}✓ Model downloaded!${NC}"
    echo "Restart SD WebUI: docker compose restart stable-diffusion-webui"
fi

echo ""
echo -e "${GREEN}Setup complete! Enjoy your Caelestia system! 🚀${NC}"
