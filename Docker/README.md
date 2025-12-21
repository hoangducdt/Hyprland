# Caelestia Docker Stack - CachyOS Edition

Hệ thống Docker tích hợp hoàn chỉnh cho CachyOS với Stable Diffusion Web UI, được tối ưu hóa cho:
- **Hardware**: ROG STRIX B550-XE + Ryzen 7 5800X + RTX 3060 12GB
- **OS**: CachyOS (Arch Linux) + Hyprland
- **GPU**: NVIDIA RTX 3060 12GB VRAM

## 🚀 Tính năng chính

### AI & Machine Learning
- **Stable Diffusion Web UI** - Tạo ảnh AI với RTX 3060
- **ComfyUI** - Node-based workflow cho Stable Diffusion
- **Open WebUI** - Giao diện chat với LLM local (LM Studio, Ollama)
- **n8n** - Tự động hóa workflow với AI

### Quản lý & Utilities
- **Nginx Proxy Manager** - Reverse proxy với SSL tự động
- **Paperless-ngx** - Quản lý tài liệu với OCR
- **FileBrowser** - Quản lý file qua web
- **Syncthing** - Đồng bộ file giữa các thiết bị
- **Duplicati** - Backup tự động

### Database & Cache
- **PostgreSQL 16** - Database chính
- **Redis 7** - Cache và message queue
- **MariaDB** - Database cho NPM

### Monitoring & Maintenance
- **Watchtower** - Auto-update containers
- **Diun** - Thông báo update
- **Autoheal** - Tự động restart unhealthy containers

## 📋 Yêu cầu hệ thống

### Phần cứng tối thiểu
- CPU: 4 cores (recommended: 8+ cores như Ryzen 7 5800X)
- RAM: 16GB (recommended: 32GB)
- GPU: NVIDIA RTX 3060 12GB hoặc tương đương
- Storage: 
  - 100GB cho Docker images/volumes
  - 200GB+ cho Stable Diffusion models
  - SSD/NVMe recommended cho models và outputs

### Phần mềm
- CachyOS hoặc Arch Linux
- **Docker Desktop** (đã cài đặt)
- NVIDIA drivers (nvidia-dkms)
- nvidia-container-toolkit

## 🔧 Cài đặt

### 1. Kiểm tra Docker Desktop và NVIDIA Container Toolkit

```bash
# Kiểm tra Docker Desktop đã chạy
docker --version
docker compose version

# Install NVIDIA drivers (nếu chưa có)
sudo pacman -S nvidia-dkms nvidia-utils nvidia-settings

# Install nvidia-container-toolkit
sudo pacman -S nvidia-container-toolkit

# Restart Docker Desktop để load nvidia-container-toolkit
# Hoặc restart qua GUI: Docker Desktop → Settings → Quit Docker Desktop
# Sau đó mở lại Docker Desktop
```

### 2. Kiểm tra GPU

```bash
# Test GPU trong Docker
docker run --rm --gpus all nvidia/cuda:12.2.0-base-ubuntu22.04 nvidia-smi

# Nếu thành công, bạn sẽ thấy thông tin GPU
```

### 3. Cấu hình Environment Variables

```bash
# Copy file example
cp _env .env

# Generate passwords
for var in POSTGRES_PASSWORD REDIS_PASSWORD NPM_DB_PASSWORD MYSQL_ROOT_PASSWORD ADMIN_PASSWORD PAPERLESS_SECRET_KEY WEBUI_SECRET_KEY; do
  echo "$var=$(openssl rand -base64 32)" >> .env
done

# Set correct permissions
chmod 600 .env

# Edit with your settings
nano .env  # hoặc vim/kate
```

**Quan trọng**: Cập nhật các giá trị sau trong `.env`:
- `DOMAIN` - Domain của bạn (hoặc localhost)
- `SSH_USER` - Username CachyOS của bạn
- `CLOUDFLARE_API_KEY` - Nếu dùng Cloudflare
- `SD_MODELS_PATH` - Đường dẫn lưu models SD (recommended: SSD riêng)
- `SD_OUTPUTS_PATH` - Đường dẫn lưu outputs

### 4. Tạo thư mục cần thiết

```bash
# Tạo thư mục cho Stable Diffusion
mkdir -p ./sd-models/Stable-diffusion
mkdir -p ./sd-models/Lora
mkdir -p ./sd-models/VAE
mkdir -p ./sd-models/embeddings
mkdir -p ./sd-outputs

# Tạo thư mục init scripts
mkdir -p ./init-scripts/postgres

# Set permissions
sudo chown -R 1000:1000 ./sd-models ./sd-outputs
```

### 5. Download Stable Diffusion Models (Optional)

```bash
# Download SD 1.5 (4GB)
cd ./sd-models/Stable-diffusion
wget https://huggingface.co/runwayml/stable-diffusion-v1-5/resolve/main/v1-5-pruned-emaonly.safetensors

# Hoặc download SDXL (6.5GB) - cần --medvram
# wget https://huggingface.co/stabilityai/stable-diffusion-xl-base-1.0/resolve/main/sd_xl_base_1.0.safetensors

cd ../..
```

### 6. Khởi động services

```bash
# Validate config
docker compose config

# Start databases first
docker compose up -d postgres redis npm-db

# Wait 30 seconds for databases to initialize
sleep 30

# Start remaining services
docker compose up -d

# Check status
docker compose ps

# View logs
docker compose logs -f
```

## 🎨 Sử dụng Stable Diffusion Web UI

### Truy cập
- URL: `http://localhost:7860`
- Hoặc qua Nginx Proxy Manager nếu đã cấu hình

### Cài đặt Extensions (Recommended)

1. Truy cập **Extensions** tab
2. Cài đặt các extension sau:
   - **ControlNet** - Control image generation
   - **Dynamic Prompts** - Advanced prompting
   - **Ultimate SD Upscale** - High-quality upscaling
   - **Tag Autocomplete** - Auto-complete prompts
   - **Image Browser** - Browse generated images
   - **Aspect Ratio Helper** - Quick aspect ratio selection

### Cấu hình tối ưu cho RTX 3060 12GB

**Settings → User Interface:**
- Quicksettings list: `sd_model_checkpoint,CLIP_stop_at_last_layers`

**Settings → System:**
- Memory: `medvram` (đã set trong docker-compose)
- VRAM: Giữ mặc định
- xFormers: Enabled (đã set)

**Settings → Optimizations:**
- Cross attention optimization: `xFormers`
- Token merging: Enable nếu muốn tăng tốc

### Recommendations cho RTX 3060

**SD 1.5:**
- Resolution: 512x512 hoặc 768x768
- Batch size: 2-4
- CFG Scale: 7-11
- Steps: 20-30

**SDXL:**
- Resolution: 1024x1024
- Batch size: 1
- CFG Scale: 7-9
- Steps: 25-35
- **Quan trọng**: Dùng `--medvram` (đã enabled)

## 🔧 ComfyUI

### Truy cập
- URL: `http://localhost:8188`

### Features
- Node-based workflow
- Chia sẻ models với SD WebUI
- Tốc độ nhanh hơn cho complex workflows
- API support

### Custom Nodes (Recommended)

```bash
# Vào container
docker exec -it comfyui bash

# Cài đặt ComfyUI Manager
cd /root/ComfyUI/custom_nodes
git clone https://github.com/ltdrdata/ComfyUI-Manager.git

# Restart container
docker restart comfyui
```

## 🌐 Nginx Proxy Manager

### First Login
1. Truy cập: `http://localhost:81`
2. Default credentials:
   - Email: `admin@example.com`
   - Password: `changeme`
3. Đổi password ngay lập tức!

### Cấu hình Proxy Hosts

**Stable Diffusion:**
- Domain: `sd.yourdomain.com`
- Forward Hostname/IP: `stable-diffusion-webui`
- Forward Port: `7860`
- Enable SSL với Let's Encrypt

**ComfyUI:**
- Domain: `comfy.yourdomain.com`
- Forward Hostname/IP: `comfyui`
- Forward Port: `8188`

**Các services khác tương tự**

## 📊 Monitoring & Maintenance

### Xem logs

```bash
# All services
docker compose logs -f

# Specific service
docker compose logs -f stable-diffusion-webui

# GPU usage
watch -n 1 nvidia-smi
```

### Backup

Duplicati tự động backup:
- PostgreSQL databases
- Redis data
- n8n workflows
- Paperless documents
- Stable Diffusion models và outputs

Truy cập: Configure qua Nginx Proxy Manager

### Updates

Watchtower tự động update containers lúc 4 AM hàng ngày.

Manual update:
```bash
docker compose pull
docker compose up -d
```

## 🐛 Troubleshooting

### GPU không được detect

```bash
# Check nvidia-smi
nvidia-smi

# Check trong Docker
docker run --rm --gpus all nvidia/cuda:12.2.0-base-ubuntu22.04 nvidia-smi

# Reinstall nvidia-container-toolkit
sudo pacman -S nvidia-container-toolkit
sudo systemctl restart docker
```

### Out of Memory (OOM)

**SDXL:**
```bash
# Edit docker-compose.yml, thêm CLI args:
--lowvram  # Nếu --medvram vẫn OOM
--no-half   # Giảm quality nhưng ít VRAM hơn
```

**SD 1.5:**
- Giảm batch size
- Giảm resolution
- Close browser tabs sử dụng GPU

### Slow Generation

```bash
# Check GPU usage
watch -n 1 nvidia-smi

# Check xFormers
docker compose logs stable-diffusion-webui | grep xformers

# Restart với force xformers
docker compose restart stable-diffusion-webui
```

### Permission Errors

```bash
# Fix ownership
sudo chown -R 1000:1000 ./sd-models ./sd-outputs

# Check permissions
ls -la
```

### Container không start

```bash
# Check logs
docker compose logs service-name

# Remove and recreate
docker compose stop service-name
docker compose rm service-name
docker compose up -d service-name
```

## 📁 Cấu trúc thư mục

```
.
├── docker-compose.yml       # Main compose file
├── .env                     # Environment variables (KHÔNG commit!)
├── init-scripts/
│   └── postgres/           # PostgreSQL init scripts
├── sd-models/              # Stable Diffusion models
│   ├── Stable-diffusion/   # Model checkpoints
│   ├── Lora/              # LoRA models
│   ├── VAE/               # VAE models
│   └── embeddings/        # Textual inversions
└── sd-outputs/            # Generated images
```

## 🔐 Security Checklist

- [ ] Đã đổi tất cả passwords mặc định
- [ ] `.env` có permission 600
- [ ] Tất cả passwords ≥ 32 characters
- [ ] Đã enable firewall (`ufw`)
- [ ] Đã configure Cloudflare proxy (nếu dùng)
- [ ] Đã enable fail2ban (optional)
- [ ] Backup `.env` file an toàn

## 📚 Resources

### Stable Diffusion
- [Civitai](https://civitai.com/) - Models, LoRAs, embeddings
- [Hugging Face](https://huggingface.co/models?pipeline_tag=text-to-image) - Official models
- [SD WebUI Wiki](https://github.com/AUTOMATIC1111/stable-diffusion-webui/wiki)

### ComfyUI
- [ComfyUI Examples](https://comfyanonymous.github.io/ComfyUI_examples/)
- [Custom Nodes](https://github.com/ltdrdata/ComfyUI-Manager)

### CachyOS
- [CachyOS Wiki](https://wiki.cachyos.org/)
- [CachyOS Discord](https://discord.gg/cachyos)

## 🤝 Contributing

Nếu bạn có improvements hoặc fixes, welcome to contribute!

## 📝 License

MIT License - Feel free to use and modify

## 🙏 Credits

Based on the Caelestia installer by hoangducdt
Optimized for CachyOS + Hyprland + RTX 3060 12GB
