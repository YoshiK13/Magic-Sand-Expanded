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

echo "=============================================="
echo " Configuring Kinect v1 support for Linux"
echo "=============================================="

# 1. Install udev rules
echo "[1/3] Configuring udev rules in /etc/udev/rules.d/51-kinect.rules..."
cat << 'EOF' > /etc/udev/rules.d/51-kinect.rules
# Kinect v1 (Xbox 360)
SUBSYSTEM=="usb", ATTR{idVendor}=="045e", ATTR{idProduct}=="02b0", MODE="0666", TAG+="uaccess"
SUBSYSTEM=="usb", ATTR{idVendor}=="045e", ATTR{idProduct}=="02ad", MODE="0666", TAG+="uaccess"
SUBSYSTEM=="usb", ATTR{idVendor}=="045e", ATTR{idProduct}=="02ae", MODE="0666", TAG+="uaccess"

# Kinect for Windows v1 (Model 1473 / K4W)
SUBSYSTEM=="usb", ATTR{idVendor}=="045e", ATTR{idProduct}=="02c2", MODE="0666", TAG+="uaccess"
SUBSYSTEM=="usb", ATTR{idVendor}=="045e", ATTR{idProduct}=="02be", MODE="0666", TAG+="uaccess"
SUBSYSTEM=="usb", ATTR{idVendor}=="045e", ATTR{idProduct}=="02bf", MODE="0666", TAG+="uaccess"
EOF

# Reload udev rules
if command -v udevadm > /dev/null 2>&1; then
  udevadm control --reload-rules || true
  udevadm trigger || true
  echo "✓ udev rules installed and reloaded."
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

# 3. Configure permanent persistence for usbfs_memory_mb=64 (multi-distro support)
echo "[3/3] Configuring persistent usbfs_memory_mb=64..."

PERSIST_OK=false

# A) systemd-tmpfiles (PRIMARY mechanism — works on Fedora, Arch, Ubuntu, Debian, SUSE, etc.)
#    Writes the value to /sys/ on every boot, regardless of whether usbcore is built-in or a module.
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

# C) Kernel command line via GRUB (universal bootloader fallback, multi-distro detection)
if [ -f /etc/default/grub ]; then
  if grep -q "usbfs_memory_mb" /etc/default/grub; then
    echo "✓ usbfs_memory_mb already present in /etc/default/grub."
  else
    echo "Adding usbcore.usbfs_memory_mb=64 to kernel boot parameters..."
    # Try GRUB_CMDLINE_LINUX_DEFAULT first, then GRUB_CMDLINE_LINUX
    if grep -q 'GRUB_CMDLINE_LINUX_DEFAULT=' /etc/default/grub; then
      sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="\(.*\)"/GRUB_CMDLINE_LINUX_DEFAULT="\1 usbcore.usbfs_memory_mb=64"/' /etc/default/grub
    elif grep -q 'GRUB_CMDLINE_LINUX=' /etc/default/grub; then
      sed -i 's/GRUB_CMDLINE_LINUX="\(.*\)"/GRUB_CMDLINE_LINUX="\1 usbcore.usbfs_memory_mb=64"/' /etc/default/grub
    fi

    # Regenerate GRUB according to the active distribution
    if command -v grubby > /dev/null 2>&1; then
      # Fedora / RHEL / CentOS (Boot Loader Specification)
      grubby --update-kernel=ALL --args="usbcore.usbfs_memory_mb=64" 2>/dev/null || true
      echo "✓ GRUB updated via grubby (Fedora/RHEL)."
    elif command -v update-grub > /dev/null 2>&1; then
      # Ubuntu / Debian / Linux Mint
      update-grub 2>/dev/null || true
      echo "✓ GRUB updated via update-grub (Debian/Ubuntu)."
    elif command -v grub2-mkconfig > /dev/null 2>&1; then
      # Fedora / openSUSE (standard path)
      if [ -f /boot/grub2/grub.cfg ]; then
        grub2-mkconfig -o /boot/grub2/grub.cfg 2>/dev/null || true
        echo "✓ GRUB updated via grub2-mkconfig."
      elif [ -f /boot/efi/EFI/fedora/grub.cfg ]; then
        grub2-mkconfig -o /boot/efi/EFI/fedora/grub.cfg 2>/dev/null || true
        echo "✓ GRUB updated (EFI/fedora)."
      fi
    elif command -v grub-mkconfig > /dev/null 2>&1; then
      # Arch / EndeavourOS / Manjaro
      if [ -f /boot/grub/grub.cfg ]; then
        grub-mkconfig -o /boot/grub/grub.cfg 2>/dev/null || true
        echo "✓ GRUB updated via grub-mkconfig (Arch)."
      fi
    fi
  fi
fi

# D) systemd-boot / bootctl (for distributions using systemd-boot like Pop!_OS, Arch variants)
if command -v bootctl > /dev/null 2>&1 && [ -d /boot/loader/entries ]; then
  for ENTRY in /boot/loader/entries/*.conf; do
    if [ -f "$ENTRY" ] && ! grep -q "usbfs_memory_mb" "$ENTRY"; then
      sed -i '/^options / s/$/ usbcore.usbfs_memory_mb=64/' "$ENTRY" 2>/dev/null || true
    fi
  done
  echo "✓ systemd-boot entries updated (if applicable)."
fi

if [ "$PERSIST_OK" = true ]; then
  echo "✓ Primary persistence configured via systemd-tmpfiles."
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
