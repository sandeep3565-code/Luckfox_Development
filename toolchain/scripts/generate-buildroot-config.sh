#!/bin/bash
# Generate proper Buildroot configuration for Rockchip830 (RV1106)

set -e

BUILDROOT_DIR="${1:-.}"
CONFIG_FILE="$BUILDROOT_DIR/.config"

if [ ! -f "$BUILDROOT_DIR/Makefile" ]; then
    echo "Error: Buildroot Makefile not found in $BUILDROOT_DIR"
    exit 1
fi

cd "$BUILDROOT_DIR"

# Start with defconfig as base
cp "$BUILDROOT_DIR/.config" "$BUILDROOT_DIR/.config.backup" 2>/dev/null || true

# Create proper configuration using multiple steps
cat > /tmp/br_config.txt << 'EOF'
# Architecture Selection
BR2_arm=y
BR2_ARM_CPU_CORTEX_A7=y
BR2_ARM_INSTRUCTIONS_THUMB2=y
BR2_ARM_FPU_NEON_VFPV4=y
BR2_ARM_ENABLE_VFP=y
BR2_ARM_EABI=y

# C Library
BR2_LIBC_UCLIBC_NG=y

# Compiler
BR2_GCC_VERSION="8.3.0"
BR2_BINUTILS_VERSION="2.32"

# Kernel Headers
BR2_LINUX_KERNEL_CUSTOM_VERSION_VALUE="5.10.66"

# Build Options
BR2_JLEVEL=0
BR2_INSTALL_LIBSTDCPP=y
EOF

# Use olddefconfig with custom config
cat /tmp/br_config.txt >> "$CONFIG_FILE"
make olddefconfig >/dev/null 2>&1

echo "Configuration generated successfully!"
echo "Target: ARM Cortex-A7 with NEON+VFPv4 (hard float)"
echo "Config saved to: $CONFIG_FILE"
