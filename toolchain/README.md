# Rockchip830 (RV1106) Toolchain Build System

Complete build system for creating ARM Rockchip830 cross-compilation toolchains using either **Buildroot** or **Crosstool-NG**.

## Overview

This system allows you to build a complete toolchain matching these exact specifications:

| Property | Value |
|----------|-------|
| **Architecture** | ARM (ARMv7-a with NEON+VFPv4) |
| **C Library** | uClibc 1.0.31 (minimal/embedded) |
| **GCC Version** | 8.3.0 |
| **Binutils** | 2.32 (with gold linker & plugins) |
| **Linux Kernel** | 5.10.66 (headers only) |
| **Target Vendor** | rockchip830 |
| **Libc Type** | Hard-float (FPU: NEON+VFPv4) |

## Build Methods Comparison

### Buildroot (Recommended)
- **Version**: Stable release (2023.11)
- **Complexity**: ⭐ Simple
- **Speed**: 30-45 minutes
- **Offline**: ✓ Uses pre-downloaded archive
- **Pros**: 
  - All-in-one solution
  - Can generate rootfs too
  - Active maintenance
  - GUI menuconfig
  - Stable release branch
  - No git clone needed
- **Cons**: Less granular control
- **Use when**: You want a complete embedded Linux build system

### Crosstool-NG (Exact Replication)
- **Version**: 1.28.0
- **Complexity**: ⭐⭐ Moderate
- **Speed**: 45-60 minutes
- **Offline**: ✓ Uses pre-downloaded archive
- **Pros**:
  - Exact control over each component
  - Exact replication of existing toolchain
  - Specialized for toolchain building
  - No git clone needed
- **Cons**: More configuration, no rootfs generation
- **Use when**: You need exact toolchain specifications

## Quick Start

### Interactive Menu
```bash
cd toolchain
make menu
# Follow prompts to select build method
```

### Direct Build - Buildroot
```bash
cd toolchain
make check-deps        # Verify dependencies
make buildroot         # Full build process
```

### Direct Build - Crosstool-NG
```bash
cd toolchain
make check-deps        # Verify dependencies
make crosstool-ng      # Full build process
```

## Offline Build (Pre-Downloaded Archives)

This build system uses **pre-downloaded archive files** for fast, offline builds:

| Archive | Size | Purpose |
|---------|------|---------|
| `buildroot-2023.11.tar.xz` | 5.3M | Buildroot stable |
| `crosstool-ng-crosstool-ng-1.28.0.zip` | 6.5M | Crosstool-NG 1.28.0 |

### Check Archives
```bash
make check-sources
```

### Benefits
✅ **No network needed** - Build offline  
✅ **Fast extraction** - Archives extract in seconds  
✅ **Reliable** - No version conflicts  
✅ **Consistent** - Same archives = same builds  

**See [OFFLINE_BUILD.md](OFFLINE_BUILD.md) for complete offline build documentation.**

## Usage Guide

### 1. Check Dependencies
```bash
make check-deps
```

Required packages:
- `gcc`, `g++`, `make` (build essentials)
- `flex`, `bison` (parser generators)
- `tar`, `unzip` (archive extraction)
- Optional: `wget`, `curl` (for manual downloads)

On Ubuntu/Debian:
```bash
sudo apt-get install build-essential flex bison tar unzip
```

### 2. Configure (Optional)
#### Buildroot
```bash
make buildroot-menuconfig
```

#### Crosstool-NG
```bash
make crosstool-menuconfig
```

### 3. Build
#### Buildroot
```bash
make buildroot-build
```

#### Crosstool-NG
```bash
make crosstool-build
```

### 4. Verify Installation
```bash
make verify-gcc
make verify-install
```

## Directory Structure

```
toolchain/
├── Makefile                          # Main build system
├── configs/                          # Configuration files
│   ├── rockchip830_defconfig         # Buildroot config
│   └── arm-rockchip830-linux-uclibcgnueabihf.defconfig  # CT-NG config
├── br-external/                      # Buildroot external recipes (optional)
├── scripts/                          # Helper scripts
├── buildroot/                        # Buildroot source (created on demand)
├── crosstool-ng/                     # Crosstool-NG source (created on demand)
└── README.md                         # This file
```

## Common Tasks

### Build Everything with Buildroot
```bash
make buildroot
# Uses stable release: 2023.11
```

### Build Everything with Crosstool-NG
```bash
make crosstool-ng
```

### Update Only Configuration
```bash
make buildroot-config    # Buildroot
make crosstool-config    # Crosstool-NG
```

### Enable Colored Output (Optional)
By default, colors are disabled for better terminal compatibility. To enable colored output:

Edit `Makefile` and uncomment the color definitions:
```makefile
# Uncomment below for colored output (if terminal supports it):
RED := \033[0;31m
GREEN := \033[0;32m
YELLOW := \033[0;33m
NC := \033[0m
```

### Clean Build Artifacts
```bash
make clean               # Remove build outputs
make distclean            # Remove everything (sources + builds)
```

### Install to Custom Location
```bash
make buildroot INSTALL_PREFIX=/custom/path
make install-buildroot
```

### Display Current Configuration
```bash
make show-config
```

### Build Information
```bash
make buildroot-info      # Buildroot details
make crosstool-info      # Crosstool-NG details
```

## Environment Variables

### INSTALL_PREFIX
Location where toolchain will be installed.

```bash
# Default
make buildroot INSTALL_PREFIX=/opt/luckfox-toolchain

# Custom location
make crosstool-ng INSTALL_PREFIX=/home/user/my-toolchain
```

### BUILD_METHOD
Select default build method (used by `make build`).

```bash
make BUILD_METHOD=crosstool-ng crosstool-ng
```

## Configuration Files

### Buildroot Config: `rockchip830_defconfig`
- Architecture: ARMv7-a
- CPU: Cortex-A7
- FPU: NEON+VFPv4
- C Library: uClibc 1.0.31
- GCC: 8.3.0

Customize:
```bash
make buildroot-menuconfig
# Make changes in GUI
# Configuration auto-saved
```

### Crosstool-NG Config: `arm-rockchip830-linux-uclibcgnueabihf.defconfig`
- Full toolchain specification
- Exact version pinning
- Binary compatibility

Customize:
```bash
make crosstool-menuconfig
# Make changes in GUI
# Configuration auto-saved
```

## Troubleshooting

### Build Fails Due to Missing Dependencies
```bash
make check-deps
# Install any missing packages shown
```

### "Permission denied" errors in Crosstool-NG
The build system auto-sets environment variables for this. If issues persist:
```bash
export CT_ALLOW_BUILD_AS_ROOT=y
export CT_ALLOW_BUILD_AS_ROOT_SURE=y
make crosstool-build
```

### Out of Disk Space
Both builds can require 10-15GB. Verify:
```bash
df -h /   # Check available space
```

### Build Timeout or Hanging
- Ensure stable internet connection
- Check firewall/proxy settings
- Run with single thread to diagnose:
```bash
# Buildroot
cd buildroot && make -j1

# Crosstool-NG
cd crosstool-build && ct-ng build.1
```

## Using the Built Toolchain

After successful build:

### Add to PATH (Buildroot)
```bash
export PATH=/opt/luckfox-toolchain/bin:$PATH
```

### Add to PATH (Crosstool-NG)
```bash
export PATH=/opt/luckfox-toolchain/bin:$PATH
```

### Verify
```bash
arm-rockchip830-linux-uclibcgnueabihf-gcc --version
arm-rockchip830-linux-uclibcgnueabihf-g++ --version
```

### Cross-compile Example
```bash
arm-rockchip830-linux-uclibcgnueabihf-gcc -o myapp main.c
file myapp
# myapp: ELF 32-bit LSB executable, ARM, EABI5 version 1
```

## Advanced Usage

### Offline Build
Pre-download sources to avoid network issues:
```bash
make buildroot-setup    # Downloads buildroot
make crosstool-setup    # Sets up crosstool-NG
```

### Rebuild Only Components
```bash
# Buildroot
cd buildroot
make clean
make

# Crosstool-NG
cd crosstool-build
ct-ng clean
ct-ng build
```

### Generate Buildroot External Recipes
Customize what gets built:
```bash
# Edit br-external/Config.in
# Add custom packages and recipes
make buildroot-menuconfig
```

### Update Configuration
```bash
# Buildroot
make savedefconfig -C buildroot

# Crosstool-NG
cd crosstool-build
ct-ng savedefconfig
```

## Make Help
```bash
make help     # Full command reference
```

## Support & Documentation

- **Buildroot**: https://buildroot.org/
- **Crosstool-NG**: http://crosstool-ng.github.io/
- **ARM Architecture**: https://developer.arm.com/
- **uClibc**: https://uclibc.org/

## License

This build system is provided as-is for Luckfox Pico development.

## Additional Resources

### Related Files
- Existing Toolchain: `/tools/linux/toolchain/arm-rockchip830-linux-uclibcgnueabihf/`
- Buildroot Documentation: [buildroot.org/docs.html](https://buildroot.org/docs.html)
- Crosstool-NG Documentation: [crosstool-ng.github.io/](http://crosstool-ng.github.io/)

### Quick Reference
```bash
# One-liner to build with Buildroot
cd toolchain && make check-deps && make buildroot

# One-liner to build with Crosstool-NG
cd toolchain && make check-deps && make crosstool-ng
```
