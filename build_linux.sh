#!/bin/bash
set -e

# ==============================================================================
# Linux Build Script for Magic Sand (AppImage Generator)
# ==============================================================================
# Features:
# 1. Reproducible build using Docker on Ubuntu 16.04 (glibc 2.23+ runtime compatibility).
# 2. Automated patch for Kinect v1 (K4W / Model 1473: FREENECT_DEVICE_CAMERA).
# 3. Wayland / XWayland compatibility shim to prevent GLFW 3.1 crash.
# 4. Mutable user data management (~/Magic-Sand/data or portable ./data):
#    Bypasses read-only AppImage filesystem (SquashFS), allowing loading and
#    saving calibrations, configuration XMLs, colormaps, and game scores.
# 5. Automated system permission setup and USB buffer memory tuning for Kinect
#    on first launch (or via ./Magic-Sand-x86_64.AppImage --setup-kinect).
# 6. Strict hardware/driver library filtering for universal compatibility across
#    any CPU (Intel/AMD) and GPU (NVIDIA proprietary, AMD Mesa, Intel Mesa).
# ==============================================================================

# Initial checks for host environment
echo "==> Checking host dependencies..."
if ! command -v docker > /dev/null 2>&1; then
    echo "ERROR: Docker is not installed on this system. Please install it to proceed."
    exit 1
fi

if ! docker info > /dev/null 2>&1; then
    echo "ERROR: Docker service is not running or the current user lacks permissions to access it."
    echo "Try starting the service (e.g., 'sudo systemctl start docker') or adding your user to the 'docker' group."
    exit 1
fi

if [ ! -f "setup_kinect_linux.sh" ]; then
    echo "ERROR: File setup_kinect_linux.sh not found in the current directory."
    exit 1
fi

# Clean up temporary build files on exit
cleanup() {
    rm -f Dockerfile.build build_inside_docker.sh
}
trap cleanup EXIT INT TERM

echo "==> [1/4] Generating Dockerfile.build..."
cat << 'DOCKER_EOF' > Dockerfile.build
FROM ubuntu:16.04

# Avoid interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Install compilation and packaging dependencies
RUN apt-get update && apt-get install -y \
    wget \
    curl \
    git \
    build-essential \
    pkg-config \
    sudo \
    fuse \
    file \
    imagemagick \
    software-properties-common \
    && rm -rf /var/lib/apt/lists/*

# Download and install openFrameworks 0.9.3
WORKDIR /opt
RUN wget -q https://openframeworks.cc/versions/v0.9.3/of_v0.9.3_linux64_release.tar.gz && \
    tar -xzf of_v0.9.3_linux64_release.tar.gz && \
    mv of_v0.9.3_linux64_release of && \
    rm of_v0.9.3_linux64_release.tar.gz

WORKDIR /opt/of/scripts/linux/ubuntu
RUN sudo ./install_dependencies.sh -y && \
    sudo ./install_codecs.sh -y || true

WORKDIR /opt/of/libs/openFrameworksCompiled/project
RUN make -j$(nproc)

# Patch ofxKinect to open FREENECT_DEVICE_CAMERA only
# Kinect for Windows (K4W / Model 1473) fails if motor or audio subdevices are requested
RUN sed -i 's/FREENECT_DEVICE_MOTOR | FREENECT_DEVICE_CAMERA/FREENECT_DEVICE_CAMERA/g' /opt/of/addons/ofxKinect/src/ofxKinect.cpp

# Download required addons for Magic Sand
WORKDIR /opt/of/addons
RUN git clone -b stable https://github.com/kylemcdonald/ofxCv.git && \
    git clone https://github.com/braitsch/ofxParagraph.git && \
    git clone https://github.com/thomwolf/ofxDatGui.git && \
    git clone https://github.com/braitsch/ofxModal.git

# Download linuxdeploy and appimagetool
WORKDIR /opt/appimage
RUN wget -q https://github.com/linuxdeploy/linuxdeploy/releases/download/continuous/linuxdeploy-x86_64.AppImage && \
    chmod +x linuxdeploy-x86_64.AppImage
RUN wget -q https://github.com/AppImage/AppImageKit/releases/download/continuous/appimagetool-x86_64.AppImage && \
    chmod +x appimagetool-x86_64.AppImage

WORKDIR /workspace

CMD ["/workspace/build_inside_docker.sh"]
DOCKER_EOF

echo "==> [2/4] Generating container build script (build_inside_docker.sh)..."
cat << 'DOCKER_EOF' > build_inside_docker.sh
#!/bin/bash
set -e

export OF_ROOT=/opt/of

# Clean objects from previous compilations
rm -rf obj

# Ensure ofxKinect camera-only patch is applied
sed -i 's/FREENECT_DEVICE_MOTOR | FREENECT_DEVICE_CAMERA/FREENECT_DEVICE_CAMERA/g' /opt/of/addons/ofxKinect/src/ofxKinect.cpp

echo "Compiling Magic-Sand..."
make APPNAME=Magic-Sand -j$(nproc)

# Ensure consistent executable binary name
if [ -f bin/workspace ] && [ ! -f bin/Magic-Sand ]; then
    mv bin/workspace bin/Magic-Sand
fi

echo "Structuring AppDir..."
rm -rf AppDir
mkdir -p AppDir/usr/bin
mkdir -p AppDir/usr/share/applications
mkdir -p AppDir/usr/share/icons/hicolor/256x256/apps
mkdir -p AppDir/usr/share/magic-sand/data

# 1. Copy executable binary
cp bin/Magic-Sand AppDir/usr/bin/

# 2. Copy master data template to usr/share/magic-sand/data and usr/bin/data
mkdir -p AppDir/usr/share/magic-sand/data
cp -r bin/data/. AppDir/usr/share/magic-sand/data/
mkdir -p AppDir/usr/bin/data
cp -r bin/data/. AppDir/usr/bin/data/

# 3. Include Kinect system permissions setup script
cp /workspace/setup_kinect_linux.sh AppDir/usr/bin/setup_kinect_linux.sh
chmod +x AppDir/usr/bin/setup_kinect_linux.sh

# 4. Generate desktop entry file
cat << 'DESKTOP_EOF' > AppDir/usr/share/applications/magicsand.desktop
[Desktop Entry]
Name=Magic Sand
Exec=Magic-Sand
Icon=magicsand
Type=Application
Categories=Game;Education;
Terminal=false
PrefersNonDefaultGPU=true
DESKTOP_EOF

# 5. Extract high-resolution application icon
convert /workspace/icon.ico[5] AppDir/usr/share/icons/hicolor/256x256/apps/magicsand.png 2>/dev/null || \
convert /workspace/icon.ico[0] AppDir/usr/share/icons/hicolor/256x256/apps/magicsand.png

# 6. Bundle shared libraries using linuxdeploy
echo "Bundling shared libraries with linuxdeploy..."
export APPIMAGE_EXTRACT_AND_RUN=1
/opt/appimage/linuxdeploy-x86_64.AppImage \
    --appdir AppDir \
    -d AppDir/usr/share/applications/magicsand.desktop \
    -i AppDir/usr/share/icons/hicolor/256x256/apps/magicsand.png \
    -e AppDir/usr/bin/Magic-Sand

# 6b. SYSTEM / HARDWARE LIBRARY PURGE
# ============================================================================
# These low-level libraries must NEVER be bundled inside an AppImage.
# They must be provided by the host system to maintain compatibility with
# the host kernel, GPU drivers (NVIDIA/AMD/Intel), and the USB subsystem.
#
# Reference: https://github.com/AppImage/pkg2appimage/blob/master/excludelist
# ============================================================================
echo "Purging system/hardware libraries that must come from the host..."

# --- Hardware and kernel (USB communication, device monitoring) ---
rm -f AppDir/usr/lib/libudev*           # Interface with systemd-udevd (netlink, must match host)
rm -f AppDir/usr/lib/libusb*            # Direct USB kernel communication (must match host)
rm -f AppDir/usr/lib/libsystemd*        # systemd IPC communication (must match host)
# NOTE: Do NOT remove libselinux.so.1 because bundled libgio-2.0 requires it,
# and distributions like Arch Linux / EndeavourOS do not include it by default.

# --- GPU drivers (NEVER bundle — each vendor provides proprietary/Mesa drivers) ---
rm -f AppDir/usr/lib/libGL.so*          # OpenGL dispatch (NVIDIA/Mesa)
rm -f AppDir/usr/lib/libGLX.so*         # GLX dispatch
rm -f AppDir/usr/lib/libGLX_*.so*       # GLX vendor-specific (nvidia, mesa)
rm -f AppDir/usr/lib/libEGL.so*         # EGL dispatch
rm -f AppDir/usr/lib/libEGL_*.so*       # EGL vendor-specific
rm -f AppDir/usr/lib/libGLdispatch*     # GLVND dispatch layer
rm -f AppDir/usr/lib/libdrm*            # Direct Rendering Manager
rm -f AppDir/usr/lib/libgbm*            # Generic Buffer Management
rm -f AppDir/usr/lib/libvulkan*         # Vulkan loader

# --- Core glibc runtime (NEVER bundle) ---
rm -f AppDir/usr/lib/libc.so*
rm -f AppDir/usr/lib/libpthread*
rm -f AppDir/usr/lib/libdl*
# Note: Use specific patterns for librt so librtmp.so is NOT accidentally purged
rm -f AppDir/usr/lib/librt.so* AppDir/usr/lib/librt-*.so
rm -f AppDir/usr/lib/libm.so*
rm -f AppDir/usr/lib/ld-linux*

echo "✓ System library purge complete."

# 7. Compile compatibility shim for Wayland / XWayland
echo "Compiling XWayland compatibility shim..."
cat << 'EOF' > /tmp/xwayland_fix.c
#define _GNU_SOURCE
#include <X11/Xlib.h>
#include <X11/XKBlib.h>
#include <stdlib.h>
#include <string.h>
#include <dlfcn.h>

static Bool (*real_XkbQueryExtension)(Display *, int *, int *, int *, int *, int *) = NULL;

Bool XkbQueryExtension(Display *dpy, int *opcode_rtrn, int *event_rtrn, int *error_rtrn, int *major_in_out, int *minor_in_out) {
    const char *wayland_display = getenv("WAYLAND_DISPLAY");
    const char *session_type = getenv("XDG_SESSION_TYPE");
    if (wayland_display || (session_type && strcmp(session_type, "wayland") == 0)) {
        return False;
    }
    if (!real_XkbQueryExtension) {
        real_XkbQueryExtension = dlsym(RTLD_NEXT, "XkbQueryExtension");
    }
    if (real_XkbQueryExtension) {
        return real_XkbQueryExtension(dpy, opcode_rtrn, event_rtrn, error_rtrn, major_in_out, minor_in_out);
    }
    return False;
}
EOF
gcc -shared -fPIC -O2 -o AppDir/usr/lib/libxwayland_fix.so /tmp/xwayland_fix.c -ldl
rm -f /tmp/xwayland_fix.c

# 8. Generate custom AppRun launcher with mutable data handling and Kinect setup
echo "Generating AppRun launcher script..."
rm -f AppDir/AppRun
cat << 'APPRUN_EOF' > AppDir/AppRun
#!/bin/bash
HERE="$(dirname "$(readlink -f "${0}")")"
# If HERE resolves inside a subdirectory, point to AppDir root
if [ ! -d "$HERE/usr/bin" ]; then
    if [ -d "$HERE/../usr/bin" ]; then
        HERE="$(readlink -f "$HERE/..")"
    elif [ -d "$HERE/../../usr/bin" ]; then
        HERE="$(readlink -f "$HERE/../..")"
    fi
fi
export APPDIR="$HERE"
export PATH="$HERE/usr/bin:$PATH"

# NOTE: LD_LIBRARY_PATH and LD_PRELOAD are intentionally NOT exported globally
# during script setup to prevent bundled libraries (such as libselinux) from
# conflicting with native host binaries (e.g., mkdir, cp, chmod, udevadm).
# They are exported right before launching the Magic Sand binary.

# ==============================================================================
# Smart Hybrid GPU Offload Dispatcher
# ==============================================================================
# On dual-GPU laptops (NVIDIA Optimus / AMD Switchable), ensure high-performance
# rendering on discrete GPU unless the user has explicitly defined another preference.
if [ -z "$__NV_PRIME_RENDER_OFFLOAD" ] && [ -d /proc/driver/nvidia ]; then
    if command -v __nv_prime_run >/dev/null 2>&1 || [ -f /usr/share/glvnd/egl_vendor.d/10_nvidia.json ] || [ -f /usr/lib/x86_64-linux-gnu/libGLX_nvidia.so.0 ] || [ -f /usr/lib64/libGLX_nvidia.so.0 ] || [ -f /usr/lib/libGLX_nvidia.so.0 ]; then
        export __NV_PRIME_RENDER_OFFLOAD=1
        export __GLX_VENDOR_LIBRARY_NAME=nvidia
        export VK_ICD_FILENAMES=/usr/share/vulkan/icd.d/nvidia_icd.json${VK_ICD_FILENAMES:+:$VK_ICD_FILENAMES}
        echo "[Magic Sand] NVIDIA discrete GPU detected: PRIME render offload enabled."
    fi
elif [ -z "$DRI_PRIME" ] && command -v lspci >/dev/null 2>&1; then
    if lspci 2>/dev/null | grep -i "VGA.*\[AMD/ATI\]" | grep -iq "Radeon"; then
        if [ "$(lspci 2>/dev/null | grep -ic "VGA\|3D")" -gt 1 ]; then
            export DRI_PRIME=1
            echo "[Magic Sand] AMD hybrid graphics detected: DRI_PRIME=1 enabled."
        fi
    fi
fi

# ==============================================================================
# A. Selection of Mutable User Data Directory
# ==============================================================================
# Determine the physical location of the .AppImage file on the host system
if [ -n "$APPIMAGE" ]; then
    APPIMAGE_DIR="$(dirname "$(readlink -f "$APPIMAGE")")"
elif [ -n "$OWD" ]; then
    APPIMAGE_DIR="$OWD"
else
    APPIMAGE_DIR="$(dirname "$(readlink -f "$0")")"
fi

# Data directory selection priority:
# Priority 1: Manual environment variable (MAGIC_SAND_DATA or OF_DATA_PATH)
# Priority 2: Portable Mode (existing 'data' or 'Magic-Sand-Data' directory beside AppImage or in current dir)
# Priority 3: Standard Mode in User Home (~/Magic-Sand/data)

if [ -n "$MAGIC_SAND_DATA" ]; then
    DATA_ROOT="$MAGIC_SAND_DATA"
elif [ -n "$OF_DATA_PATH" ]; then
    DATA_ROOT="$OF_DATA_PATH"
elif [ -d "$APPIMAGE_DIR/data" ]; then
    DATA_ROOT="$APPIMAGE_DIR/data"
elif [ -d "$APPIMAGE_DIR/Magic-Sand-Data" ]; then
    DATA_ROOT="$APPIMAGE_DIR/Magic-Sand-Data"
elif [ -n "$OWD" ] && [ -d "$OWD/data" ]; then
    DATA_ROOT="$OWD/data"
elif [ -n "$OWD" ] && [ -d "$OWD/Magic-Sand-Data" ]; then
    DATA_ROOT="$OWD/Magic-Sand-Data"
else
    DATA_ROOT="${HOME:-/home/$USER}/Magic-Sand/data"
fi

DATA_CONTAINER="$(dirname "$DATA_ROOT")"
mkdir -p "$DATA_CONTAINER" 2>/dev/null || true

# ==============================================================================
# B. Host Support and Configuration for Kinect v1
# ==============================================================================
setup_kinect_system() {
    local SCRIPT="$HERE/usr/bin/setup_kinect_linux.sh"
    if [ ! -f "$SCRIPT" ]; then
        echo "! Configuration script not found: $SCRIPT"
        return 1
    fi

    echo "=========================================================="
    echo " Configuring udev rules and USB memory for Kinect v1"
    echo "=========================================================="

    if [ "$EUID" -eq 0 ]; then
        "$SCRIPT"
        return $?
    elif command -v pkexec > /dev/null 2>&1; then
        pkexec "$SCRIPT"
        return $?
    elif [ -t 0 ] && command -v sudo > /dev/null 2>&1; then
        sudo "$SCRIPT"
        return $?
    elif command -v kdialog > /dev/null 2>&1; then
        if kdialog --title "Magic Sand" --yesno "System configuration required for Kinect sensor permissions and USB buffer memory.\n\nDo you want to apply this configuration now? (Requires administrator password)"; then
            if command -v pkexec > /dev/null 2>&1; then
                pkexec "$SCRIPT"
            elif command -v sudo > /dev/null 2>&1; then
                sudo "$SCRIPT"
            fi
        fi
        return $?
    elif command -v zenity > /dev/null 2>&1; then
        if zenity --question --title="Magic Sand" --text="System configuration required for Kinect sensor permissions and USB buffer memory.\n\nDo you want to apply this configuration now? (Requires administrator password)"; then
            if command -v pkexec > /dev/null 2>&1; then
                pkexec "$SCRIPT"
            elif command -v sudo > /dev/null 2>&1; then
                sudo "$SCRIPT"
            fi
        fi
        return $?
    else
        echo "! No terminal or GUI dialog detected to request permission elevation."
        echo "  Please execute manually: sudo $SCRIPT"
        return 1
    fi
}

# Run setup or uninstall if explicitly requested via parameter
if [ "$1" = "--setup" ] || [ "$1" = "--setup-kinect" ]; then
    setup_kinect_system
    exit $?
fi

if [ "$1" = "--uninstall" ] || [ "$1" = "--uninstall-kinect" ]; then
    UNINSTALL_SCRIPT="$HERE/usr/bin/setup_kinect_linux.sh"
    if [ "$EUID" -eq 0 ]; then
        "$UNINSTALL_SCRIPT" --uninstall
        exit $?
    elif command -v pkexec > /dev/null 2>&1; then
        pkexec "$UNINSTALL_SCRIPT" --uninstall
        exit $?
    elif [ -t 0 ] && command -v sudo > /dev/null 2>&1; then
        sudo "$UNINSTALL_SCRIPT" --uninstall
        exit $?
    else
        echo "Please execute: sudo $UNINSTALL_SCRIPT --uninstall"
        exit 1
    fi
fi

# Check if udev rules and adequate USB buffer memory exist on the host
KINECT_RULES="/etc/udev/rules.d/51-kinect.rules"
KINECT_PROMPT_FLAG="$DATA_CONTAINER/.kinect_prompted"

# Read current USB buffer memory (unprivileged read from sysfs)
CURRENT_USB_MB=$(cat /sys/module/usbcore/parameters/usbfs_memory_mb 2>/dev/null || echo "0")

# Check if system setup is required:
#   1. Missing Kinect udev rules
#   2. USB buffer memory is less than 64 MB (insufficient for Kinect v1 dual streaming)
NEEDS_SETUP=false
if [ ! -f "$KINECT_RULES" ]; then
    echo "[Magic Sand] Kinect udev rules not detected."
    NEEDS_SETUP=true
fi
if [ "$CURRENT_USB_MB" -lt 64 ] 2>/dev/null; then
    echo "[Magic Sand] Current USB buffer: ${CURRENT_USB_MB} MB (64 MB required for Kinect)."
    NEEDS_SETUP=true
fi

if [ "$NEEDS_SETUP" = true ]; then
    if [ ! -f "$KINECT_PROMPT_FLAG" ] || [ -t 0 ]; then
        echo "[Magic Sand] Initiating Kinect system configuration..."
        setup_kinect_system || true
        touch "$KINECT_PROMPT_FLAG" 2>/dev/null || true
    fi
fi

# Opportunistic runtime bump if write permissions to sysfs exist
if [ -w /sys/module/usbcore/parameters/usbfs_memory_mb ]; then
    CURRENT_USB_MB=$(cat /sys/module/usbcore/parameters/usbfs_memory_mb 2>/dev/null || echo "0")
    if [ "$CURRENT_USB_MB" -lt 64 ] 2>/dev/null; then
        echo 64 > /sys/module/usbcore/parameters/usbfs_memory_mb 2>/dev/null || true
    fi
fi

# ==============================================================================
# C. Preparation and Synchronization of Mutable User Data
# ==============================================================================
# Ensure required directory tree
mkdir -p "$DATA_ROOT/settings"
mkdir -p "$DATA_ROOT/colorMaps"
mkdir -p "$DATA_ROOT/mapGame/Scores"
mkdir -p "$DATA_ROOT/mapGame/ReferenceData"
mkdir -p "$DATA_ROOT/mapGame/DebugFiles"
mkdir -p "$DATA_ROOT/boidGame/DebugFiles"
mkdir -p "$DATA_ROOT/DebugFiles"

# Master template data bundled inside AppImage
TEMPLATE_DATA="$HERE/usr/share/magic-sand/data"
[ ! -d "$TEMPLATE_DATA" ] && TEMPLATE_DATA="$HERE/usr/bin/data"

# Synchronize missing master data files, preserving user changes (-n: no-clobber)
if [ -d "$TEMPLATE_DATA" ]; then
    cp -rn "$TEMPLATE_DATA/." "$DATA_ROOT/" 2>/dev/null || true
fi

# Guarantee that vital XML configuration files exist and are not empty
for XML_REL in \
    "settings/calibration.xml" \
    "settings/kinectProjectorSettings.xml" \
    "settings/sandSurfaceRendererSettings.xml" \
    "mapGame/ReferenceData/MapReferenceSettings.xml" \
    "colorMaps/HeightColorMap.xml"
do
    TARGET_XML="$DATA_ROOT/$XML_REL"
    SOURCE_XML="$TEMPLATE_DATA/$XML_REL"
    if [ ! -s "$TARGET_XML" ] && [ -f "$SOURCE_XML" ]; then
        mkdir -p "$(dirname "$TARGET_XML")"
        cp -f "$SOURCE_XML" "$TARGET_XML"
    fi
done

# Ensure read and write permissions for the user
chmod -R u+rwX "$DATA_ROOT" 2>/dev/null || true

# Export data path environment variable for openFrameworks
export OF_DATA_PATH="$DATA_ROOT"

echo "[Magic Sand] Active data directory: $DATA_ROOT"

# Change working directory to data container (so relative paths 'data/...' resolve)
cd "$DATA_CONTAINER"

# Export runtime library paths and shims for the Magic Sand binary
export LD_LIBRARY_PATH="$HERE/usr/lib${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
if [ -f "$HERE/usr/lib/libxwayland_fix.so" ]; then
    export LD_PRELOAD="$HERE/usr/lib/libxwayland_fix.so${LD_PRELOAD:+:$LD_PRELOAD}"
fi

# Execute the Magic Sand binary forwarding all arguments
exec "$HERE/usr/bin/Magic-Sand" "$@"
APPRUN_EOF
chmod +x AppDir/AppRun

# 9. Create final AppImage with appimagetool
echo "Packaging AppImage with appimagetool..."
export APPIMAGE_EXTRACT_AND_RUN=1
/opt/appimage/appimagetool-x86_64.AppImage AppDir Magic-Sand-x86_64.AppImage
[ ! "Magic-Sand-x86_64.AppImage" -ef "/workspace/Magic-Sand-x86_64.AppImage" ] && mv Magic-Sand-x86_64.AppImage /workspace/ || true
chmod 777 /workspace/Magic-Sand-x86_64.AppImage

echo "==> AppImage created successfully."
DOCKER_EOF
chmod +x build_inside_docker.sh

if [ "$1" = "--rebuild" ] || ! docker image inspect magic-sand-appimage-builder > /dev/null 2>&1; then
    echo "==> [3/4] Building Docker image..."
    docker build -t magic-sand-appimage-builder -f Dockerfile.build .
else
    echo "==> [3/4] Docker image 'magic-sand-appimage-builder' found locally. Reusing (use --rebuild to force rebuild)."
fi

echo "==> [4/4] Running compilation and packaging inside Docker container..."
docker run --rm -v "$(pwd):/workspace" --privileged magic-sand-appimage-builder

echo "=============================================================================="
echo " Build completed successfully!"
echo " Output file: Magic-Sand-x86_64.AppImage"
echo ""
echo " Usage notes:"
echo " - Mutable data: Saved and loaded from ~/Magic-Sand/data/"
echo "   (or ./data directory beside AppImage when portable mode is used)."
echo " - First launch: Will request elevated permissions to configure"
echo "   Kinect udev rules and USB buffer memory."
echo " - Manual Kinect setup can also be triggered via:"
echo "   ./Magic-Sand-x86_64.AppImage --setup (or --setup-kinect)"
echo "=============================================================================="
