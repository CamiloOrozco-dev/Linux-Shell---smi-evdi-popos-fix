#!/bin/bash
# Script de instalación automatizada para Silicon Motion en Pop!_OS Wayland

echo "1. Desactivando compresión de video Intel (CCS)..."
grep -q "INTEL_DEBUG=noccs" /etc/environment || echo "INTEL_DEBUG=noccs" >> /etc/environment

echo "2. Configurando permisos USB (udev)..."
cat > /etc/udev/rules.d/99-smi-usb.rules << UDEV_EOF
SUBSYSTEM=="usb", ATTR{idVendor}=="090c", ATTR{idProduct}=="0768", MODE="0666", GROUP="plugdev"
SUBSYSTEM=="drm", KERNEL=="card*", GROUP="video", MODE="0666"
UDEV_EOF
udevadm control --reload-rules && udevadm trigger

echo "3. Instalando dependencias y compilando libevdi 1.14.11..."
apt update && apt install --reinstall -y evdi-dkms libevdi1 git build-essential
rm -rf /tmp/evdi-1.14.11
git clone --branch v1.14.11 --depth 1 https://github.com/DisplayLink/evdi.git /tmp/evdi-1.14.11
cd /tmp/evdi-1.14.11/library
make -j$(nproc) && make install && ldconfig

echo "4. Configurando script de arranque inteligente..."
cat > /opt/siliconmotion/start-smi.sh << 'SCRIPT_EOF'
#!/bin/bash
sudo rmmod evdi 2>/dev/null
sudo modprobe evdi initial_device_count=1
sleep 3
export XDG_RUNTIME_DIR=/run/user/$(id -u)
for s in "$XDG_RUNTIME_DIR"/wayland-*; do
  if [ -S "$s" ]; then
    export WAYLAND_DISPLAY=$(basename "$s")
    break
  fi
done
[ -z "$WAYLAND_DISPLAY" ] && export WAYLAND_DISPLAY=wayland-1
exec sudo XDG_RUNTIME_DIR=$XDG_RUNTIME_DIR WAYLAND_DISPLAY=$WAYLAND_DISPLAY /opt/siliconmotion/SMIUSBDisplayManager
SCRIPT_EOF
chmod +x /opt/siliconmotion/start-smi.sh

echo "5. Configurando permisos sudoers y Autostart..."
echo "$(logname) ALL=(ALL) NOPASSWD: /opt/siliconmotion/SMIUSBDisplayManager, /opt/siliconmotion/start-smi.sh, /sbin/modprobe, /sbin/rmmod" > /etc/sudoers.d/smiusbdisplay
chmod 0440 /etc/sudoers.d/smiusbdisplay

sudo -u $(logname) mkdir -p /home/$(logname)/.config/autostart
sudo -u $(logname) cat > /home/$(logname)/.config/autostart/smiusbdisplay.desktop << AUTOSTART_EOF
[Desktop Entry]
Type=Application
Name=Silicon Motion USB Display
Exec=/opt/siliconmotion/start-smi.sh
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
AUTOSTART_EOF

echo "✅ Instalación completada. Reinicia el sistema."
