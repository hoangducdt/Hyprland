# Caelestia Installer - Thiết Lập Hoàn Chỉnh Cho CachyOS

**Công cụ cài đặt tự động hoàn chỉnh** cho hệ thống CachyOS với Hyprland, được tối ưu hóa cho gaming, phát triển phần mềm, AI/ML, và sáng tạo nội dung 3D/2D.

## 🖥️ Cấu Hình Phần Cứng Mục Tiêu

- **Bo mạch chủ**: ASUS ROG STRIX B550-XE GAMING WIFI
- **CPU**: AMD Ryzen 7 5800X (8 nhân / 16 luồng)
- **GPU**: NVIDIA GeForce RTX 3060 12GB
- **RAM**: 32GB DDR4 (khuyến nghị)
- **Hệ điều hành**: CachyOS (dựa trên Arch Linux)

---

## 🚀 Cài Đặt

### Yêu Cầu Trước Khi Cài
- CachyOS đã được cài đặt
- Kết nối internet ổn định
- Quyền sudo

### Cài đặt bằng một dòng lệnh (Khuyến nghị)
```bash
curl -fsSL https://raw.githubusercontent.com/hoangducdt/caelestia/main/install.sh | bash
```

### Cài đặt thủ công
```bash
git clone https://github.com/hoangducdt/caelestia.git
cd caelestia
chmod +x install.sh
./install.sh
```

### Tính Năng Script
- ✅ **Quản lý trạng thái**: Tự động lưu tiến trình, có thể tiếp tục nếu bị gián đoạn
- ✅ **Sao lưu tự động**: Backup các file cấu hình quan trọng
- ✅ **Xử lý xung đột**: Tự động giải quyết xung đột gói
- ✅ **Cơ chế thử lại**: Tự động thử lại khi cài đặt thất bại
- ✅ **Ghi log chi tiết**: Log đầy đủ tại `~/setup_complete_*.log`

⏱️ **Thời gian cài đặt**: 30-90 phút (tùy thuộc vào tốc độ mạng)

---

## 📦 Các Thành Phần Được Cài Đặt

### 1. Cập Nhật Hệ Thống & Công Cụ Cơ Bản
- Cập nhật hệ thống với CachyOS keyrings
- Cài đặt các công cụ cơ bản: `yay`, `base-devel`, `git`, `wget`, `curl`

### 2. Tối Ưu Hóa NVIDIA (Chỉ Cấu Hình - Không Thay Đổi Driver)
**Quan trọng**: Script chỉ tối ưu hóa cấu hình, **KHÔNG cài đặt driver NVIDIA**. Sử dụng driver gốc của CachyOS.

**Các tối ưu hóa được áp dụng**:
```bash
# Cấu hình Modprobe
- nvidia_drm modeset=1 fbdev=1
- NVreg_PreserveVideoMemoryAllocations=1
- NVreg_UsePageAttributeTable=1
- NVreg_DynamicPowerManagement=0x02
- NVreg_EnableGpuFirmware=0

# Module Mkinitcpio
- nvidia, nvidia_modeset, nvidia_uvm, nvidia_drm

# Dịch vụ quản lý nguồn
- nvidia-suspend.service
- nvidia-hibernate.service
- nvidia-resume.service
```

### 3. Cấu Hình Caelestia
**Môi trường desktop**: Hyprland + cấu hình Caelestia từ repository

**Các file cấu hình được cài đặt**:
- Symbolic links từ `~/.local/share/caelestia/Configs/*` → `~/.config/*`
- Tự động sao lưu cấu hình cũ với timestamp
- Scripts Hyprland với quyền thực thi
- Fastfetch với logo tùy chỉnh
- Cấu hình terminal Kitty
- Giao diện GTK-3.0 và bookmarks

### 4. Gói Meta (180+ gói)

#### Caelestia Core
```
caelestia-cli, caelestia-shell, hyprland
xdg-desktop-portal-gtk, xdg-desktop-portal-hyprland
hyprpicker, cliphist, inotify-tools
app2unit, trash-cli, eza, jq
adw-gtk-theme, papirus-icon-theme
qt5ct-kde, qt6ct-kde
todoist-appimage, uwsm, direnv
```

#### Công Cụ Hệ Thống
```
fish, kitty, wl-clipboard
qt5-wayland, qt6-wayland
gnome-keyring, polkit-gnome
thunar, tumbler, ffmpegthumbnailer, libgsf
```

#### Hệ Thống File & Nén
```
btrfs-progs, exfatprogs, ntfs-3g, dosfstools
zip, unzip, p7zip, unrar, rsync, tmux
```

#### Công Cụ Shell
```
starship, eza, bat, ripgrep, fd, fzf, zoxide
```

#### Công Cụ Giám Sát
```
htop, btop, neofetch, fastfetch
nvtop, amdgpu_top, iotop, iftop
```

#### Quản Lý Đĩa
```
gparted, gnome-disk-utility
```

#### Công Cụ PDF
```
zathura, zathura-pdf-poppler
```

#### Mạng
```
networkmanager, network-manager-applet
nm-connection-editor
```

### 5. Python & AI/ML Stack

#### Python Cơ Bản
```
python, python-pip, python-virtualenv
python-numpy, python-pandas
jupyter-notebook, python-scikit-learn
python-matplotlib, python-pillow, python-scipy
```

#### CUDA & Deep Learning
```
cuda, cudnn
python-pytorch-cuda
python-torchvision-cuda
python-torchaudio-cuda
python-transformers, python-accelerate
```

#### Công Cụ AI
```
ollama-cuda
```

### 6. Âm Thanh
```
pipewire, pipewire-pulse, pipewire-alsa, pipewire-jack
wireplumber, pavucontrol, helvum
v4l2loopback-dkms
gstreamer-vaapi
noise-suppression-for-voice
```

### 7. Đa Phương Tiện

#### Trình Phát Video
```
mpv, vlc
```

#### Xem/Chỉnh Sửa Ảnh
```
imv, gimp, inkscape
```

#### Sản Xuất Âm Thanh
```
audacity, ardour
```

#### Chỉnh Sửa Video
```
kdenlive, obs-studio
```

#### Codec & Thư Viện Đa Phương Tiện
```
gst-plugins-good, gst-plugins-bad
gst-plugins-ugly, gst-libav
ffmpeg, lib32-ffmpeg
gstreamer, gst-plugins-base
libvorbis, lib32-libvorbis
opus, lib32-opus
flac, lib32-flac
x264, x265
```

#### Tăng Tốc Phần Cứng
```
libva-nvidia-driver
```

### 8. Công Cụ Phát Triển

#### Trình Soạn Thảo Code
```
neovim, codium (thay thế VS Code)
```

#### Quản Lý Phiên Bản
```
git, github-cli
```

#### Công Cụ Build
```
cmake, ninja, meson
```

#### Trình Biên Dịch
```
gcc, clang
```

#### Ngôn Ngữ Lập Trình
```
nodejs, npm, rust, go
```

#### Container
```
docker, docker-compose
```

#### Cơ Sở Dữ Liệu
```
postgresql, redis
```

#### Kiểm Thử API
```
postman-bin
```

#### Phát Triển .NET
```
dotnet-sdk, dotnet-runtime
dotnet-sdk-9.0, dotnet-sdk-8.0
aspnet-runtime
mono, mono-msbuild
```

### 9. Gaming Stack

#### CachyOS Gaming Meta
```
cachyos-gaming-meta
  ├─ alsa-plugins
  ├─ giflib, lib32-giflib
  ├─ glfw
  ├─ gst-plugins-base-libs, lib32-gst-plugins-base-libs
  ├─ gtk3, lib32-gtk3
  ├─ libjpeg-turbo, lib32-libjpeg-turbo
  ├─ libva, lib32-libva
  ├─ mpg123, lib32-mpg123
  ├─ ocl-icd, opencl-icd-loader, lib32-opencl-icd-loader
  ├─ openal, lib32-openal
  ├─ proton-cachyos-slr
  ├─ umu-launcher
  ├─ protontricks
  ├─ ttf-liberation
  ├─ wine-cachyos-opt
  ├─ winetricks
  └─ vulkan-tools

cachyos-gaming-applications
  ├─ gamescope
  ├─ goverlay
  ├─ heroic-games-launcher
  ├─ lib32-mangohud, mangohud
  ├─ lutris
  ├─ steam
  └─ wqy-zenhei
```

#### Thành Phần Gaming Bổ Sung
```
lib32-vulkan-icd-loader
lib32-nvidia-utils
vulkan-icd-loader
gamemode, lib32-gamemode
xpadneo-dkms (hỗ trợ tay cầm Xbox)
protonup-qt (quản lý Proton-GE)
```

### 10. Blender & Sáng Tạo 3D

#### Blender Core
```
blender
```

#### Phụ Thuộc Blender
```
openimagedenoise  # AI denoising
opencolorio       # Quản lý màu sắc
opensubdiv        # Bề mặt phân chia
openvdb           # Dữ liệu thể tích
embree            # Ray tracing
openimageio       # Xử lý ảnh I/O
alembic           # Trao đổi hoạt hình
openjpeg2         # JPEG 2000
openexr           # Ảnh HDR
libspnav          # Hỗ trợ chuột 3D
```

### 11. Bộ Công Cụ Sáng Tạo

#### Chỉnh Sửa Ảnh
```
gimp, gimp-plugin-gmic
krita              # Vẽ kỹ thuật số
darktable          # Quy trình xử lý RAW
rawtherapee        # Chỉnh sửa RAW nâng cao
```

#### Đồ Họa Vector
```
inkscape
```

#### Chỉnh Sửa Video
```
kdenlive
frei0r-plugins
mediainfo, mlt
davinci-resolve
natron             # Compositing/VFX
```

#### Sản Xuất Âm Thanh
```
audacity, ardour   # Digital Audio Workstation
```

#### Xuất Bản
```
scribus            # Xuất bản desktop
```

#### Công Cụ Hỗ Trợ
```
imagemagick, graphicsmagick
potrace, fontforge
```

### 12. Tối Ưu Hóa Hệ Thống

#### Công Cụ Hiệu Suất
```
irqbalance         # Cân bằng tải IRQ
cpupower           # Điều chỉnh tần số CPU
thermald           # Quản lý nhiệt độ
tlp                # Quản lý nguồn
powertop           # Phân tích tiêu thụ điện
preload            # Tải trước ứng dụng
```

### 13. Công Cụ Hiển Thị & Màn Hình
```
wlr-randr, kanshi, nwg-displays
```

### 14. Ứng Dụng Chuyên Nghiệp
```
microsoft-edge-stable-bin
docker-desktop
rider              # JetBrains C# IDE
github-desktop
lmstudio           # Giao diện LLM cục bộ
```

### 15. Streaming & Ghi Hình
```
obs-vaapi
obs-nvfbc
obs-vkcapture
obs-websocket
```

### 16. Giao Tiếp
```
vesktop-bin        # Discord với Vencord
```

### 17. Điều Khiển Phần Cứng
```
openrgb            # Điều khiển đèn LED RGB
```

### 18. Bộ Gõ Tiếng Việt
```
fcitx5
fcitx5-qt, fcitx5-gtk
fcitx5-configtool
fcitx5-bamboo-git
```

### 19. Trình Quản Lý Hiển Thị
```
gdm, gdm-settings
```

### 20. Font Chữ
```
ttf-jetbrains-mono-nerd
adobe-source-code-pro-fonts
ttf-liberation
ttf-dejavu
```

---

## ⚙️ Cấu Hình Hệ Thống

### 1. Tối Ưu Hóa Gaming
- Kích hoạt kho multilib (hỗ trợ 32-bit)
- Thêm người dùng vào nhóm `gamemode`
- Cấu hình MangoHud cho RTX 3060

**Cấu hình MangoHud** (`~/.config/MangoHud/MangoHud.conf`):
```
legacy_layout=false
horizontal
gpu_stats, cpu_stats, ram, vram
fps, frametime, frame_timing
vulkan_driver, wine, engine_version
gamemode
```

### 2. Thiết Lập Phát Triển
- Bật dịch vụ Docker
- Thêm người dùng vào nhóm `docker`
- Docker Compose sẵn sàng

### 3. Cấu Hình Đa Phương Tiện
- Bật dịch vụ Pipewire (cấp người dùng):
  - pipewire.service
  - pipewire-pulse.service
  - wireplumber.service

### 4. Thiết Lập AI/ML
- Bật và khởi động dịch vụ Ollama
- Cấu hình CUDA toolkit

### 5. Cấu Hình Streaming
- Tải module kernel v4l2loopback
- Module tự động tải khi khởi động qua `/etc/modules-load.d/v4l2loopback.conf`

### 6. Tối Ưu Hóa Hệ Thống (Ryzen 7 5800X)

#### CPU Governor
```bash
# Chế độ hiệu suất cho desktop
cpupower frequency-set -g performance

# Dịch vụ systemd đã tạo:
/etc/systemd/system/cpupower-performance.service
```

#### Dịch Vụ Đã Bật
```bash
irqbalance.service
thermald.service
tlp.service
cpupower-performance.service
```

#### Cấu Hình TLP
```
CPU_SCALING_GOVERNOR_ON_AC=performance
CPU_ENERGY_PERF_POLICY_ON_AC=performance
```

#### Tham Số Kernel (`/etc/sysctl.d/99-ryzen-optimization.conf`)
```
# Tối ưu hóa Ryzen 7 5800X
vm.swappiness=10
vm.vfs_cache_pressure=50
vm.dirty_ratio=10
vm.dirty_background_ratio=5

# Hiệu suất mạng
net.core.default_qdisc=cake
net.ipv4.tcp_congestion_control=bbr

# Hệ thống file
fs.inotify.max_user_watches=524288
```

#### Quy Tắc I/O Scheduler (`/etc/udev/rules.d/60-ioschedulers.rules`)
```
# BFQ cho HDD/SSD để tăng khả năng phản hồi
ACTION=="add|change", KERNEL=="sd[a-z]*", ATTR{queue/scheduler}="bfq"

# None cho NVMe (đã tối ưu sẵn)
ACTION=="add|change", KERNEL=="nvme[0-9]*", ATTR{queue/scheduler}="none"
```

### 7. Cấu Hình DNS

**Systemd-resolved** (`/etc/systemd/resolved.conf`):
```
DNS=1.1.1.1#cloudflare-dns.com 1.0.0.1#cloudflare-dns.com 
    2606:4700:4700::1111#cloudflare-dns.com 
    2606:4700:4700::1001#cloudflare-dns.com

FallbackDNS=9.9.9.9#dns.quad9.net 2620:fe::9#dns.quad9.net 
            1.1.1.1#cloudflare-dns.com 2606:4700:4700::1111#cloudflare-dns.com 
            8.8.8.8#dns.google 2001:4860:4860::8888#dns.google

DNSOverTLS=yes
```

### 8. Cấu Hình IP Tĩnh

**Hồ sơ NetworkManager** (`/etc/NetworkManager/system-connections/static-ethernet.nmconnection`):
```
[connection]
id=static-ethernet
type=ethernet
interface-name=<interface-được-phát-hiện>
autoconnect=true

[ipv4]
method=manual
address1=192.168.1.2/24,192.168.1.1
dns=1.1.1.1;1.0.0.1;

[ipv6]
method=auto
```

### 9. Cấu Trúc Thư Mục

#### Thư Mục Người Dùng
```
~/Desktop
~/Documents
~/Downloads
~/Music
~/Videos
~/Pictures/Wallpapers (với git clone từ mylinuxforwork)
~/OneDrive
```

#### Thư Mục Dự Án
```
~/AI-Projects
~/AI-Models
~/Creative-Projects
~/Blender-Projects
```

#### Thư Mục Cấu Hình
```
~/.local/bin
~/.config/hypr/scripts
~/.config/caelestia
~/.config/hypr/hyprland
~/.config/fastfetch/logo
~/.config/kitty
~/.config/xfce4
~/.config/gtk-3.0
```

#### GTK Bookmarks (`~/.config/gtk-3.0/bookmarks`)
```
file://$HOME/Downloads
file://$HOME/Documents
file://$HOME/Pictures
file://$HOME/Videos
file://$HOME/Music
file://$HOME/OneDrive
```

---

## 🔧 Các Bước Sau Cài Đặt

### 1. Yêu Cầu Khởi Động Lại
```bash
sudo reboot
```
Các thay đổi sau cần khởi động lại:
- Cấu hình module kernel NVIDIA
- Cài đặt CPU governor
- Dịch vụ Systemd
- Cấu hình mạng

### 2. Kiểm Tra Thiết Lập NVIDIA
```bash
nvidia-smi
```
Nên thấy GPU được nhận diện và phiên bản driver.

### 3. Kiểm Tra Gaming
```bash
# Bật gamemode cho Steam
gamemoderun %command%

# Kiểm tra MangoHud
mangohud glxgears
```

### 4. Cấu Hình GPU Blender
```bash
# Khởi động Blender
blender

# Đi đến: Edit → Preferences → System → Cycles Render Devices
# Chọn: OptiX
# Bật: GeForce RTX 3060
```

### 5. Khởi Động Dịch Vụ AI
```bash
# Kiểm tra Ollama đang chạy
sudo systemctl status ollama

# Kiểm tra CUDA
python -c "import torch; print(torch.cuda.is_available())"
```

### 6. Cấu Hình Bộ Gõ Tiếng Việt
```bash
# Khởi động Cấu hình Fcitx5
fcitx5-configtool

# Thêm phương thức nhập Bamboo
# Cấu hình phím tắt (mặc định: Ctrl+Space)
```

### 7. Thiết Lập GDM
```bash
# GDM sẽ tự động khởi động lần khởi động tiếp theo
# Cấu hình với:
gdm-settings
```

---

## 📊 Hiệu Suất Dự Kiến

### CPU (Ryzen 7 5800X)
```
Cơ bản: 3.8 GHz
Boost: Tới 4.7 GHz (đơn nhân)
Tất cả nhân bền vững: 4.4-4.5 GHz
Nhiệt độ (idle): 40-50°C
Nhiệt độ (tải): 70-80°C
Công suất: 105W TDP, 142W PPT
```

### GPU (RTX 3060 12GB)
```
Xung nhịp boost: 1777 MHz
Bộ nhớ: 12GB GDDR6 @ 15 Gbps
Nhiệt độ (idle): 30-40°C
Nhiệt độ (tải): 60-75°C
Công suất: 170W TDP
CUDA Compute: 8.6
Tensor Cores: Có (tăng tốc AI)
RT Cores: Gen 2
```

### Render Blender (Cycles OptiX)
```
Cảnh đơn giản (1M đa giác): 2-5 phút
Cảnh phức tạp (10M+ đa giác): 10-30 phút
Hoạt hình (250 khung hình): 2-8 giờ
Viewport: Thời gian thực với 128-256 mẫu
```

### Hiệu Suất Gaming
```
1080p Ultra: 60-144 FPS (esports)
1080p High/Ultra: 40-90 FPS (AAA titles)
Tương thích Proton/Wine: 80%+ game hoạt động
Hiệu suất so với Windows: 90-95%
```

### Khả Năng AI/ML (12GB VRAM)
```
✅ Llama 3.2 3B (3GB VRAM) - Nhanh
✅ Mistral 7B (4-5GB VRAM) - Cân bằng
✅ Llama 3.1 8B (5-6GB VRAM) - Chất lượng cao
✅ CodeLlama 7B (4-5GB VRAM) - Lập trình
⚠️ Mixtral 8x7B (6-8GB VRAM) - Lượng tử hóa 4-bit
✅ Stable Diffusion 1.5 (512x512) - Nhanh
✅ SDXL (1024x1024) - Dùng --medvram
✅ ControlNet - Hoạt động tốt
```

---

## 🛠️ Khắc Phục Sự Cố

### Vấn Đề Driver NVIDIA
```bash
# Kiểm tra trạng thái driver
pacman -Qi nvidia-utils

# Xác minh module kernel
lsmod | grep nvidia

# Kiểm tra tối ưu hóa đã được áp dụng
cat /etc/modprobe.d/nvidia.conf
cat /etc/mkinitcpio.conf
```

### Vấn Đề Hiệu Suất Gaming
```bash
# Bật gamemode
systemctl --user status gamemoded

# Kiểm tra MangoHud
cat ~/.config/MangoHud/MangoHud.conf

# Xác minh multilib
grep -A1 "\[multilib\]" /etc/pacman.conf
```

### Docker Từ Chối Quyền
```bash
# Kiểm tra nhóm docker
groups $USER

# Nếu không trong nhóm docker, đăng xuất và đăng nhập lại
# Hoặc chạy:
newgrp docker
```

### Blender Không Sử Dụng GPU
```bash
# Kiểm tra CUDA
nvidia-smi

# Xác minh CUDA toolkit
pacman -Qi cuda

# Trong Blender:
# Edit → Preferences → System → Cycles Render Devices → OptiX
```

### Bộ Gõ Tiếng Việt Không Hoạt Động
```bash
# Khởi động Fcitx5
fcitx5 &

# Đặt biến môi trường (thêm vào ~/.profile hoặc ~/.bash_profile):
export GTK_IM_MODULE=fcitx
export QT_IM_MODULE=fcitx
export XMODIFIERS=@im=fcitx
```

### OBS NVENC Không Khả Dụng
```bash
# Cài đặt CUDA
sudo pacman -S cuda

# Kiểm tra tăng tốc phần cứng ffmpeg
ffmpeg -hwaccels

# Khởi động lại OBS
```

---

## 📝 Vị Trí File Quan Trọng

### Log & Trạng Thái
```
~/setup_complete_*.log              # Log cài đặt
~/.cache/caelestia-setup/setup_state.json  # Trạng thái thiết lập (để tiếp tục)
~/Documents/caelestia-configs-*     # Backup cấu hình
```

### File Cấu Hình
```
~/.local/share/caelestia/           # Repository Caelestia
~/.config/                          # Cấu hình người dùng (symlinked)
/etc/modprobe.d/nvidia.conf         # Cài đặt modprobe NVIDIA
/etc/mkinitcpio.conf                # Module khởi động sớm
/etc/systemd/resolved.conf          # Cấu hình DNS
/etc/NetworkManager/system-connections/  # Hồ sơ mạng
/etc/sysctl.d/99-ryzen-optimization.conf  # Tham số kernel
/etc/udev/rules.d/60-ioschedulers.rules   # I/O scheduler
```

---

## 🎯 Trường Hợp Sử Dụng

### 1. Nghệ Sĩ 3D / Animator
- Blender với render OptiX (nhanh gấp 3-5 lần CPU)
- Hiệu suất viewport thời gian thực
- 12GB VRAM cho cảnh phức tạp
- Compositing tăng tốc GPU

### 2. Nhà Thiết Kế Đồ Họa
- GIMP cho chỉnh sửa ảnh
- Inkscape cho đồ họa vector
- Krita cho vẽ kỹ thuật số
- Darktable cho quy trình RAW

### 3. Biên Tập Video / Streamer
- Kdenlive/DaVinci cho chỉnh sửa
- OBS với NVENC (không mất FPS)
- Render hiệu ứng GPU
- Streaming độ trễ thấp

### 4. Lập Trình Viên Game
- Phát triển .NET (C#)
- Bộ công cụ đầy đủ: Rider, VS Code
- Docker cho container hóa
- Blender cho tạo tài sản

### 5. Lập Trình Viên AI/ML
- Suy luận LLM cục bộ (Ollama)
- Tạo Stable Diffusion
- PyTorch/TensorFlow GPU
- Jupyter notebooks
- Hỗ trợ CUDA 8.6

### 6. Game Thủ
- Steam + Proton-GE
- Lutris cho game không Steam
- GameMode cho hiệu suất
- MangoHud cho giám sát
- Hỗ trợ đầy đủ tay cầm Xbox

---

## 💾 Yêu Cầu Dung Lượng Đĩa

### Cài Đặt Mới
```
Hệ thống cơ bản: ~15GB
Công cụ gaming: ~5GB
Phát triển: ~8GB
Công cụ AI/ML: ~10GB
Bộ sáng tạo: ~5GB
Tổng cộng: ~43GB
```

### Sau Khi Sử Dụng
```
Dự án Blender: 5-50GB
Mô hình AI: 20-50GB
Cài đặt game: tùy thuộc (10-100GB mỗi game)
Dự án video: 50-200GB
Dung lượng trống khuyến nghị: 200-500GB
```

---

## 📋 Tính Năng Script

### Quản Lý Trạng Thái
- Theo dõi trạng thái dựa trên JSON
- Khả năng tiếp tục khi bị gián đoạn
- Theo dõi các bước hoàn thành/thất bại/cảnh báo
- Ghi log với timestamp

### Hệ Thống Backup
- Tự động sao lưu các file hệ thống đã sửa đổi
- Backup có timestamp trong `~/Documents/`
- Bảo toàn cấu hình gốc

### Quản Lý Gói
- Phát hiện gói thông minh (kho chính thức vs AUR)
- Giải quyết xung đột tự động
- Cơ chế thử lại với backoff theo cấp số nhân
- Bảo vệ timeout cho build AUR
- Bỏ qua các gói đã cài đặt

### Xử Lý Lỗi
- Ghi log toàn diện
- Đầu ra mã hóa màu
- Cảnh báo không nghiêm trọng
- Dừng lỗi nghiêm trọng với tham chiếu log

### Tính Năng An Toàn
- Không tự động cài đặt driver
- Xác nhận ghi đè cấu hình
- Backup trước khi sửa đổi
- Cơ chế duy trì sudo

---

## ⚠️ Lưu Ý Quan Trọng

### Về Driver NVIDIA
⚠️ **QUAN TRỌNG**: Script này KHÔNG cài đặt driver NVIDIA. Driver đã được tích hợp sẵn trên kernel của CachyOS:
```bash
# Có thể thay đổi giữa mã nguồn **ĐÓNG** và mã nguồn **MỞ**
# Mã nguồn đóng:
sudo pacman -S linux-cachyos-nvidia
# Mã nguồn mở:
sudo pacman -S linux-cachyos-nvidia-open
```

Script chỉ tối ưu hóa cấu hình để có hiệu suất tốt hơn.

### Cấu Hình Mạng
Script đặt IP tĩnh `192.168.1.2/24` với gateway `192.168.1.1`. Sửa đổi trong script nếu mạng của bạn sử dụng địa chỉ khác.

### Kho Multilib
Tự động bật để hỗ trợ gaming 32-bit. Nếu cần bật thủ công:
```bash
sudo nano /etc/pacman.conf
# Bỏ comment phần [multilib]
sudo pacman -Sy
```

---

## 🌟 Điểm Nổi Bật

### Hiệu Suất
- ✅ **CPU Governor**: Chế độ hiệu suất cho tốc độ tối đa
- ✅ **I/O Scheduler**: BFQ cho khả năng phản hồi, none cho NVMe
- ✅ **Mạng**: Kiểm soát tắc nghẽn BBR + CAKE qdisc
- ✅ **Bộ nhớ**: Tối ưu hóa vm.swappiness và áp lực cache

### Gaming
- ✅ **Proton-GE**: Lớp tương thích mới nhất
- ✅ **GameMode**: Tối ưu hóa CPU tự động
- ✅ **MangoHud**: Overlay hiệu suất thời gian thực
- ✅ **NVIDIA**: Tăng tốc phần cứng mọi thứ

### Sáng Tạo
- ✅ **Blender OptiX**: Ray tracing tăng tốc AI
- ✅ **NVENC**: Mã hóa không mất hiệu suất
- ✅ **Bộ hoàn chỉnh**: Thay thế chuyên nghiệp cho Adobe
- ✅ **12GB VRAM**: Không giới hạn với dự án phức tạp

### Phát Triển
- ✅ **Full .NET Stack**: SDK 8.0 + 9.0 + ASP.NET
- ✅ **Container**: Docker + Docker Compose
- ✅ **Nhiều ngôn ngữ**: C#, C++, Rust, Go, Node.js
- ✅ **IDE chuyên nghiệp**: Rider, VS Code

### AI/ML
- ✅ **CUDA 12**: Toolkit mới nhất + cuDNN
- ✅ **PyTorch**: Hỗ trợ CUDA đầy đủ
- ✅ **Ollama**: Suy luận LLM cục bộ
- ✅ **12GB VRAM**: Chạy mô hình 7B-8B thoải mái

---

## 📚 Tài Liệu Bổ Sung

### Cấu Trúc Script
Script được tổ chức thành các module:
- **Quản lý trạng thái**: Theo dõi tiến trình và cho phép tiếp tục
- **Quản lý gói**: Cài đặt thông minh với xử lý lỗi
- **Hệ thống backup**: Bảo vệ cấu hình hiện có
- **Các hàm thiết lập**: Cài đặt và cấu hình module

### Luồng Thực Thi
1. Khởi tạo và kiểm tra quyền sudo
2. Cập nhật hệ thống
3. Tối ưu hóa NVIDIA (chỉ cấu hình)
4. Cài đặt gói meta
5. Thiết lập gaming
6. Cài đặt công cụ phát triển
7. Cấu hình đa phương tiện
8. Thiết lập AI/ML
9. Công cụ streaming
10. Tối ưu hóa hệ thống
11. Cài đặt GDM
12. Tạo thư mục
13. Áp dụng cấu hình

### Tùy Chỉnh
Để tùy chỉnh cài đặt, chỉnh sửa mảng gói trong các hàm tương ứng:
- `setup_meta_packages()`: Gói hệ thống cơ bản
- `setup_gaming()`: Công cụ gaming
- `setup_development()`: Công cụ phát triển
- `setup_ai_ml()`: Stack AI/ML

### Khôi Phục Từ Lỗi
Nếu script thất bại:
1. Kiểm tra log tại `~/setup_complete_*.log`
2. Chạy lại script - nó sẽ tiếp tục từ nơi dừng
3. Nếu vấn đề vẫn tiếp diễn, xóa trạng thái và thử lại:
   ```bash
   rm -rf ~/.cache/caelestia-setup/
   ./install.sh
   ```

### Gỡ Cài Đặt
Để gỡ bỏ cấu hình Caelestia:
```bash
# Xóa symbolic links
rm -rf ~/.config/hypr
rm -rf ~/.config/fastfetch
rm -rf ~/.config/kitty
# ... (xóa các cấu hình khác nếu cần)

# Khôi phục từ backup
cp -r ~/Documents/caelestia-configs-*/hypr ~/.config/
```

Để gỡ cài đặt các gói:
```bash
# Liệt kê các gói đã cài
pacman -Qe | grep caelestia

# Gỡ cài đặt
sudo pacman -Rns <tên-gói>
```

---

## 🔍 Câu Hỏi Thường Gặp

### Câu hỏi: Tôi có thể chạy script nhiều lần không?
Đáp: Có, script được thiết kế để bỏ qua các bước đã hoàn thành và chỉ cài đặt những gì thiếu.

### Câu hỏi: Script có hoạt động trên các bản phân phối khác không?
Đáp: Script được tối ưu hóa cho CachyOS. Một số phần có thể hoạt động trên Arch Linux, nhưng không được đảm bảo.

### Câu hỏi: Làm thế nào để cập nhật cấu hình Caelestia?
Đáp: Cấu hình được symlink từ repository, chỉ cần pull code mới:
```bash
cd ~/.local/share/caelestia
git pull
# Các symlink sẽ tự động trỏ đến cấu hình mới
# Reload Hyprland nếu đang chạy: hyprctl reload
```

### Câu hỏi: Tôi có thể tùy chỉnh cấu hình không?
Đáp: Có, sau khi cài đặt, tất cả cấu hình đều ở `~/.config/`. Chỉnh sửa trực tiếp hoặc gỡ symlink và tạo cấu hình riêng.

### Câu hỏi: Script có an toàn không?
Đáp: Có, script:
- Không cài đặt driver tự động
- Backup tất cả cấu hình trước khi sửa đổi
- Có thể xem và kiểm tra mã nguồn
- Chỉ sử dụng kho chính thức và AUR đáng tin cậy

### Câu hỏi: Tôi cần bao nhiêu dung lượng đĩa?
Đáp: Tối thiểu 50GB cho cài đặt cơ bản, khuyến nghị 200-500GB cho sử dụng thực tế với dự án.

### Câu hỏi: Hiệu suất so với Windows như thế nào?
Đáp: Gaming: 90-95% hiệu suất Windows với Proton. Công việc sáng tạo và phát triển: thường ngang bằng hoặc tốt hơn nhờ tối ưu hóa hệ thống.

---

**Made with ❤️ for ROG STRIX B550-XE | Ryzen 7 5800X | RTX 3060 12GB**

**Ready to game, develop, create, and render! 🚀🎮💻🎨**
