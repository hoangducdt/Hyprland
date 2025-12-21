# Docker Desktop Configuration for Caelestia

## 🐳 Docker Desktop trên CachyOS

Hệ thống này được thiết kế để chạy với **Docker Desktop** thay vì Docker Engine standalone.

## ✅ Ưu điểm của Docker Desktop

1. **GUI Management** - Quản lý containers qua giao diện đồ họa
2. **Kubernetes Support** - Tích hợp sẵn Kubernetes
3. **Extensions** - Nhiều extensions hữu ích
4. **Easy Updates** - Cập nhật dễ dàng qua GUI
5. **Không cần sudo** - Không cần add user vào docker group

## ⚙️ Cấu hình Docker Desktop cho GPU

### 1. Cài đặt NVIDIA Container Toolkit

```bash
# Cài đặt nvidia-container-toolkit
sudo pacman -S nvidia-container-toolkit

# Restart Docker Desktop
# Method 1: Qua GUI
# Docker Desktop → Settings → Quit Docker Desktop
# Sau đó mở lại Docker Desktop

# Method 2: Qua CLI (nếu có systemd service)
# systemctl --user restart docker-desktop
```

### 2. Verify GPU Support

```bash
# Test GPU trong Docker
docker run --rm --gpus all nvidia/cuda:12.2.0-base-ubuntu22.04 nvidia-smi

# Nếu thấy output của nvidia-smi là thành công!
```

### 3. Cấu hình Docker Desktop Settings

Mở **Docker Desktop → Settings**:

#### Resources
- **CPUs**: Recommended 8+ (hoặc tất cả)
- **Memory**: Recommended 16GB minimum, 24GB+ for SDXL
- **Swap**: 4GB
- **Disk**: 200GB+ (cho models và outputs)

#### Docker Engine
Thêm cấu hình sau vào `daemon.json`:

```json
{
  "runtimes": {
    "nvidia": {
      "path": "nvidia-container-runtime",
      "runtimeArgs": []
    }
  },
  "default-runtime": "nvidia",
  "features": {
    "buildkit": true
  },
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  }
}
```

Click **Apply & Restart**

## 🚀 Deployment với Docker Desktop

### Quick Start

```bash
# 1. Ensure Docker Desktop is running
docker info

# 2. Run quick start script
./quick-start.sh

# Or manual:
docker compose up -d
```

### Quản lý qua GUI

**Containers Tab:**
- View tất cả containers đang chạy
- Start/Stop/Restart containers
- View logs real-time
- Open in terminal

**Images Tab:**
- Quản lý images
- Pull new images
- Delete unused images

**Volumes Tab:**
- View và quản lý volumes
- Backup volumes

## 📊 Monitoring với Docker Desktop

### Dashboard View
- CPU/Memory usage per container
- Network activity
- Logs aggregation

### Docker Extensions (Recommended)

1. **Resource Usage Extension** - Monitor resource consumption
2. **Logs Explorer** - Advanced log viewing
3. **Disk Usage** - Analyze disk space

Install từ: Docker Desktop → Add Extensions

## 🔧 Troubleshooting

### GPU không được detect

```bash
# 1. Check nvidia-container-toolkit
pacman -Q nvidia-container-toolkit

# 2. Reinstall nếu cần
sudo pacman -S --needed nvidia-container-toolkit

# 3. Restart Docker Desktop hoàn toàn
# Quit Docker Desktop
# Chờ 10 giây
# Mở lại Docker Desktop

# 4. Test lại
docker run --rm --gpus all nvidia/cuda:12.2.0-base-ubuntu22.04 nvidia-smi
```

### Docker Desktop không start

```bash
# Check logs
journalctl --user -u docker-desktop -n 100

# Clear data và restart
rm -rf ~/.docker/desktop
# Sau đó mở lại Docker Desktop
```

### Out of Memory

Tăng memory limit trong Docker Desktop Settings:
- Settings → Resources → Memory
- Recommended: 24GB+ cho SDXL

### Slow Performance

1. **Enable BuildKit**:
   - Settings → Docker Engine
   - Thêm `"features": { "buildkit": true }`

2. **Allocate More Resources**:
   - Settings → Resources
   - Tăng CPUs và Memory

3. **Use SSD for Docker Data**:
   - Settings → Resources → Disk image location
   - Chọn SSD/NVMe path

## 🎯 Best Practices

### Resource Allocation

**Cho Stable Diffusion + Other Services:**
- CPUs: 12-14 (để lại 2-4 cho host)
- Memory: 24GB (để lại 8GB cho host)
- Disk: Đặt trên SSD/NVMe

### Maintenance

```bash
# Clean up unused resources
docker system prune -a --volumes

# Qua GUI:
# Troubleshoot → Clean/Purge data
```

### Backup

```bash
# Export volumes
docker run --rm -v volume_name:/data -v $(pwd):/backup \
  alpine tar czf /backup/volume_name.tar.gz -C /data .

# Import volumes
docker run --rm -v volume_name:/data -v $(pwd):/backup \
  alpine tar xzf /backup/volume_name.tar.gz -C /data
```

## 🔄 Updates

**Docker Desktop:**
- Check for updates: Help → Check for Updates
- Auto-update: Settings → General → Automatically check for updates

**Containers:**
- Watchtower tự động update hàng ngày lúc 4 AM
- Manual: `docker compose pull && docker compose up -d`

## 📚 Tài liệu thêm

- [Docker Desktop Documentation](https://docs.docker.com/desktop/)
- [NVIDIA Container Toolkit](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/)
- [Docker Compose Reference](https://docs.docker.com/compose/compose-file/)

## 💡 Tips

1. **Pin Docker Desktop to Taskbar** - Dễ dàng access
2. **Enable Dev Environments** - Test changes nhanh
3. **Use Docker Desktop Extensions** - Enhance functionality
4. **Regular Backups** - Backup `.env` và volumes quan trọng
5. **Monitor Resource Usage** - Đảm bảo không overload

## ⚠️ Lưu ý quan trọng

- Docker Desktop cần **license** cho business use (>250 employees hoặc >$10M revenue)
- Cho personal/educational use: **FREE**
- Alternative: Podman Desktop hoặc standalone Docker Engine

---

**Hệ thống đã được tối ưu để chạy tốt nhất với Docker Desktop trên CachyOS!** 🚀
