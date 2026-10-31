#!/bin/bash
set -e

# ==============================================================================
# Setup script for Kinect v1 on Linux (Ubuntu, Debian, Fedora, Arch, etc.)
# Requires root privileges (sudo)
# ==============================================================================

if [ "$EUID" -ne 0 ]; then
  echo "Please run this script as root or with sudo:"
  echo "  sudo ./setup_kinect_linux.sh"
  exit 1
fi

# Reversible uninstallation flag
if [ "$1" = "--uninstall" ]; then
  echo "=============================================="
  echo " Removing Kinect v1 Linux configuration..."
  echo "=============================================="
  rm -f /etc/udev/rules.d/51-kinect.rules
  if command -v udevadm > /dev/null 2>&1; then
    udevadm control --reload-rules || true
    udevadm trigger || true
  fi
  rm -f /etc/tmpfiles.d/kinect-usbfs.conf
  rm -f /etc/modprobe.d/usbcore.conf
  echo "✓ Kinect v1 rules and persistence files removed successfully."
  exit 0
fi

echo "=============================================="
echo " Configuring Kinect v1 support for Linux"
echo "=============================================="

# 1. Install udev rules
echo "[1/3] Configuring udev rules in /etc/udev/rules.d/51-kinect.rules..."
cat << 'EOF' > /etc/udev/rules.d/51-kinect.rules
# Kinect v1 (Xbox 360)
SUBSYSTEM=="usb", ATTR{idVendor}=="045e", ATTR{idProduct}=="02b0", MODE="0666", TAG+="uaccess", TEST=="power/control", ATTR{power/control}="on", ATTR{power/autosuspend}="-1"
SUBSYSTEM=="usb", ATTR{idVendor}=="045e", ATTR{idProduct}=="02ad", MODE="0666", TAG+="uaccess", TEST=="power/control", ATTR{power/control}="on", ATTR{power/autosuspend}="-1"
SUBSYSTEM=="usb", ATTR{idVendor}=="045e", ATTR{idProduct}=="02ae", MODE="0666", TAG+="uaccess", TEST=="power/control", ATTR{power/control}="on", ATTR{power/autosuspend}="-1"

# Kinect for Windows v1 (Model 1473 / K4W)
SUBSYSTEM=="usb", ATTR{idVendor}=="045e", ATTR{idProduct}=="02c2", MODE="0666", TAG+="uaccess", TEST=="power/control", ATTR{power/control}="on", ATTR{power/autosuspend}="-1"
SUBSYSTEM=="usb", ATTR{idVendor}=="045e", ATTR{idProduct}=="02be", MODE="0666", TAG+="uaccess", TEST=="power/control", ATTR{power/control}="on", ATTR{power/autosuspend}="-1"
SUBSYSTEM=="usb", ATTR{idVendor}=="045e", ATTR{idProduct}=="02bf", MODE="0666", TAG+="uaccess", TEST=="power/control", ATTR{power/control}="on", ATTR{power/autosuspend}="-1"
EOF

# Reload udev rules
if command -v udevadm > /dev/null 2>&1; then
  udevadm control --reload-rules || true
  udevadm trigger || true
  echo "✓ udev rules installed (with USB autosuspend disabled) and reloaded."
else
  echo "! udevadm not found; please restart the system to apply rules."
fi

# 2. Increase USB buffer memory in runtime (usbfs_memory_mb)
echo "[2/3] Setting usbfs_memory_mb to 64 MB..."
if [ -f /sys/module/usbcore/parameters/usbfs_memory_mb ]; then
  echo 64 > /sys/module/usbcore/parameters/usbfs_memory_mb
  echo "✓ USB buffer memory temporarily set to 64 MB."
else
  echo "! usbcore module parameter path not available at runtime."
fi

# 3. Configure non-invasive persistence for usbfs_memory_mb=64 (multi-distro standard)
echo "[3/3] Configuring non-invasive persistence for usbfs_memory_mb=64..."

PERSIST_OK=false

# A) systemd-tmpfiles (PRIMARY standard — works on Fedora, Arch, Ubuntu, Debian, SUSE, Pop!_OS, etc.)
#    Writes the value to /sys/ on every boot via standard systemd service, without modifying bootloaders.
if command -v systemd-tmpfiles > /dev/null 2>&1; then
  mkdir -p /etc/tmpfiles.d
  echo "w /sys/module/usbcore/parameters/usbfs_memory_mb - - - - 64" > /etc/tmpfiles.d/kinect-usbfs.conf
  systemd-tmpfiles --create /etc/tmpfiles.d/kinect-usbfs.conf 2>/dev/null || true
  echo "✓ systemd-tmpfiles configured (/etc/tmpfiles.d/kinect-usbfs.conf)."
  PERSIST_OK=true
fi

# B) modprobe.d (fallback for distributions where usbcore is loaded as a kernel module)
if [ -d /etc/modprobe.d ]; then
  echo "options usbcore usbfs_memory_mb=64" > /etc/modprobe.d/usbcore.conf
  echo "✓ File /etc/modprobe.d/usbcore.conf configured (applies if usbcore is a module)."
fi

if [ "$PERSIST_OK" = true ]; then
  echo "✓ Non-invasive persistence configured via systemd-tmpfiles."
else
  echo "⚠ systemd-tmpfiles not available. USB buffer may require manual reset after reboot."
fi

echo ""
echo "=============================================="
echo " Configuration complete."
echo " IMPORTANT RECOMMENDATIONS:"
echo " 1. If your computer has USB 3.0 (blue/red) and USB 2.0 (black) ports,"
echo "    ALWAYS connect the Kinect v1 to a native USB 2.0 port or a USB 2.0 HUB."
echo " 2. Ensure the Kinect external 12V power supply adapter is plugged into the wall."
echo "=============================================="
