# GUIDE.md - Complete Toolchain Build System Guide

## Table of Contents
1. [Overview](#overview)
2. [System Requirements](#system-requirements)
3. [Getting Started](#getting-started)
4. [Building the Toolchain](#building-the-toolchain)
5. [Advanced Usage](#advanced-usage)
6. [Troubleshooting](#troubleshooting)

---

## Overview

This is a professional-grade build system for creating ARM Rockchip830 cross-compilation toolchains. It supports **two different approaches**:

- **Buildroot**: Complete embedded Linux build framework (recommended for most users)
- **Crosstool-NG**: Specialized toolchain builder with fine-grained control

### Key Specifications
```
Target:          ARM Rockchip830 (RV1106)
Architecture:    ARMv7-a (32-bit)
FPU:            NEON + VFPv4 (hardware floating point)
C Library:       uClibc 1.0.31 (minimal/embedded)
GCC Version:     8.3.0
Binutils:        2.32 (with gold linker)
Kernel Headers:  Linux 5.10.66
Languages:       C, C++
```

---

## System Requirements

### Minimum Hardware
- **CPU**: 2+ cores recommended
- **RAM**: 4GB minimum, 8GB recommended
- **Disk**: 20GB free (buildroot), 15GB free (crosstool-ng)
- **Network**: Stable internet connection (downloads ~1-2GB)

### Ubuntu/Debian Dependencies
```bash
sudo apt-get update
sudo apt-get install -y \
    build-essential \
    git \
    flex \
    bison \
    wget \
    curl \
    python3 \
    texinfo \
    help2man \
    gawk \
    libtool \
    libtool-bin
```

---

## Getting Started

### 1. Navigate to Toolchain Directory
```bash
cd ~/apps/Luckfox_Development/toolchain
```

### 2. Check Installation
```bash
make help
```

You should see a comprehensive menu of available commands.

### 3. Verify Dependencies
```bash
make check-deps
```

This checks for all required build tools and reports any missing packages.

### 4. Start Interactive Build
```bash
make menu
```

This launches an interactive menu to select your preferred build method.

---

## Building the Toolchain

### Method 1: Buildroot (Recommended)

#### Full Build (Start to Finish)
```bash
cd ~/apps/Luckfox_Development/toolchain
make check-deps              # Verify dependencies
make buildroot               # Full build process
```

#### Step-by-Step Build

**Step 1: Setup**
```bash
make buildroot-setup
# Downloads and prepares Buildroot (~200MB)
# Uses stable release: 2023.11
```

**Step 2: Configure (Optional)**
```bash
make buildroot-menuconfig
# GUI configuration interface
# Use arrow keys to navigate
# Space to select/deselect
# Exit: save and quit
```

Common configurations to adjust:
- `Target Architecture` → ARM
- `Target Architecture Variant` → cortex-A7
- `Floating Point Strategy` → Hard (FPU)
- `C library` → uClibc-ng
- `GCC version` → 8.3.0

**Step 3: Build**
```bash
make buildroot-build
# Starts compilation (30-45 minutes)
```

**Step 4: Verify**
```bash
make verify-gcc
```

#### Result
Toolchain location: `./buildroot/output/host/bin`

```bash
ls -la buildroot/output/host/bin/ | grep arm-rockchip
```

---

### Method 2: Crosstool-NG (For Exact Control)

#### Full Build
```bash
cd ~/apps/Luckfox_Development/toolchain
make check-deps              # Verify dependencies
make crosstool-ng            # Full build process
```

#### Step-by-Step Build

**Step 1: Setup**
```bash
make crosstool-setup
# Clones crosstool-ng, configures, and installs locally
# (~300MB)
```

**Step 2: Configure (Optional)**
```bash
make crosstool-menuconfig
# Opens Crosstool-NG configuration
```

Key settings:
- `Paths & misc options` → Prefix directory: `/opt/luckfox-toolchain`
- `Target options` → Architecture: ARM, CPU: cortex-A7
- `Target options` → FPU: neon-vfpv4
- `OS` → Linux, Kernel: 5.10.66
- `C library` → uClibc, Version: 1.0.31
- `Compiler` → GCC version: 8.3.0

**Step 3: Build**
```bash
make crosstool-build
# Starts compilation (45-60 minutes)
```

**Step 4: Verify**
```bash
make verify-gcc
```

#### Result
Toolchain location: `/opt/luckfox-toolchain/bin` (or custom prefix)

---

## Using the Built Toolchain

### Add to PATH (Temporary Session)
```bash
# For Buildroot
source scripts/add-to-path.sh buildroot

# For Crosstool-NG
source scripts/add-to-path.sh crosstool-ng
```

### Add to PATH (Permanent)

#### For Bash (~/.bashrc)
```bash
# Add this line to ~/.bashrc
export PATH="/home/sandeepkumar/apps/Luckfox_Development/toolchain/buildroot/output/host/bin:$PATH"

# Or for Crosstool-NG:
export PATH="/opt/luckfox-toolchain/bin:$PATH"

# Then reload:
source ~/.bashrc
```

#### For Zsh (~/.zshrc)
Same as Bash, but edit `~/.zshrc` instead.

#### For Fish (~/.config/fish/config.fish)
```fish
set -gx PATH /path/to/toolchain/bin $PATH
```

### Verify Installation
```bash
arm-rockchip830-linux-uclibcgnueabihf-gcc --version
arm-rockchip830-linux-uclibcgnueabihf-g++ --version
```

Expected output:
```
arm-rockchip830-linux-uclibcgnueabihf-gcc (GCC) 8.3.0
...
```

---

## Cross-Compiling with the Toolchain

### Compile a Simple C Program
```bash
cat > hello.c << 'EOF'
#include <stdio.h>

int main() {
    printf("Hello from Rockchip830!\n");
    return 0;
}
EOF

arm-rockchip830-linux-uclibcgnueabihf-gcc -o hello hello.c
```

### Verify Binary Format
```bash
file hello
# Output: hello: ELF 32-bit LSB executable, ARM, EABI5 version 1
```

### Compile C++ Program
```bash
cat > hello.cpp << 'EOF'
#include <iostream>

int main() {
    std::cout << "Hello from C++!" << std::endl;
    return 0;
}
EOF

arm-rockchip830-linux-uclibcgnueabihf-g++ -o hello_cpp hello.cpp
```

### Common Compiler Flags
```bash
# Optimization
-O2             # Standard optimization
-O3             # Aggressive optimization
-Os             # Size optimization (embedded)

# Architecture
-march=armv7-a  # Target ARMv7-a
-mcpu=cortex-a7 # Optimize for Cortex-A7
-mfpu=neon-vfpv4  # Use NEON+VFPv4
-mfloat-abi=hard  # Hardware float ABI

# Example: Optimized compile for RV1106
arm-rockchip830-linux-uclibcgnueabihf-gcc \
    -march=armv7-a \
    -mcpu=cortex-a7 \
    -mfpu=neon-vfpv4 \
    -mfloat-abi=hard \
    -O2 \
    -o myapp main.c
```

### Linking Against Libraries
```bash
# Link with math library
arm-rockchip830-linux-uclibcgnueabihf-gcc -o app main.c -lm

# Link with pthread
arm-rockchip830-linux-uclibcgnueabihf-gcc -o app main.c -pthread

# Link multiple libraries
arm-rockchip830-linux-uclibcgnueabihf-gcc -o app main.c -lm -lpthread
```

---

## Advanced Usage

### Custom Installation Path
```bash
# Build with custom installation directory
make crosstool-build INSTALL_PREFIX=/home/user/my-toolchain
```

### Offline Build
Pre-download all sources before building (useful for restricted networks):

```bash
# Buildroot
cd buildroot
make source

# Crosstool-NG
mkdir -p crosstool-src
# Manually download sources listed in configuration
```

### Rebuild Only Components
```bash
# Rebuild Buildroot
cd buildroot
make clean
make

# Rebuild Crosstool-NG
cd crosstool-build
ct-ng clean
ct-ng build
```

### Export Configuration
Save your configuration for reproducible builds:

```bash
# Buildroot
make -C buildroot savedefconfig
cp buildroot/defconfig configs/my_config_defconfig

# Crosstool-NG
cd crosstool-build
ct-ng savedefconfig
```

### Using with CMake
```cmake
# CMakeLists.txt
set(CMAKE_SYSTEM_NAME Linux)
set(CMAKE_SYSTEM_PROCESSOR ARM)
set(CMAKE_C_COMPILER arm-rockchip830-linux-uclibcgnueabihf-gcc)
set(CMAKE_CXX_COMPILER arm-rockchip830-linux-uclibcgnueabihf-g++)
set(CMAKE_FIND_ROOT_PATH /opt/luckfox-toolchain)
```

Build:
```bash
mkdir build && cd build
cmake ..
make
```

### Using with Autotools
```bash
./configure \
    --host=arm-rockchip830-linux-uclibcgnueabihf \
    --prefix=/usr \
    CC=arm-rockchip830-linux-uclibcgnueabihf-gcc \
    CXX=arm-rockchip830-linux-uclibcgnueabihf-g++

make
make DESTDIR=./staging install
```

---

## Troubleshooting

### Color Output Not Working (Showing Escape Codes)
Colors are disabled by default for better terminal compatibility. If you see `\033[0;32m` codes:

This is normal behavior. Colors are intentionally disabled in the default configuration.

**To enable colored output**, edit `Makefile` and uncomment the color definitions:
```bash
# In Makefile, find the "Colors for output" section and change from:
RED := 
GREEN := 
# To:
RED := \033[0;31m
GREEN := \033[0;32m
```

Or use the `sed` command:
```bash
sed -i 's/^RED :=.*/RED := \\033[0;31m/' Makefile
sed -i 's/^GREEN :=.*/GREEN := \\033[0;32m/' Makefile
sed -i 's/^YELLOW :=.*/YELLOW := \\033[0;33m/' Makefile
sed -i 's/^NC :=.*/NC := \\033[0m/' Makefile
```

### Build Fails with "Permission Denied"
```bash
# Crosstool-NG specific - set environment variables
export CT_ALLOW_BUILD_AS_ROOT=y
export CT_ALLOW_BUILD_AS_ROOT_SURE=y
make crosstool-build
```

### "gcc not found" or Missing Tools
```bash
# Verify all dependencies
make check-deps

# Install missing packages
sudo apt-get install build-essential flex bison
```

### Out of Disk Space
```bash
# Check available space
df -h /

# Clean up
make clean          # Remove build artifacts
make distclean       # Remove everything

# Move to larger partition
mv toolchain /mnt/larger-disk/
```

### Download Failures
```bash
# Retry with single-threaded download
cd buildroot
make BR2_JLEVEL=1 all

# Or manually download sources
wget <url> -P buildroot/dl/
```

### Build Hangs or Times Out
```bash
# Single-threaded build for debugging
cd buildroot
make -j1 all

# Check logs
tail -f /tmp/buildroot.log
```

### "Cannot execute binary" after compilation
```bash
# Check target architecture
file myapp
# Should show: ARM, EABI5 version 1

# If wrong, verify toolchain is in PATH
which arm-rockchip830-linux-uclibcgnueabihf-gcc
```

### Sysroot Not Found
```bash
# Check GCC installation
arm-rockchip830-linux-uclibcgnueabihf-gcc -print-sysroot

# Verify files exist
ls -la /opt/luckfox-toolchain/arm-rockchip830-linux-uclibcgnueabihf/sysroot/
```

---

## Directory Structure Reference

```
toolchain/
├── Makefile                          # Main build system
├── README.md                         # Project documentation
├── GUIDE.md                          # This file
├── configs/                          # Configuration files
│   ├── rockchip830_defconfig         # Buildroot config
│   └── arm-rockchip830-linux-uclibcgnueabihf.defconfig  # CT-NG config
├── br-external/                      # Buildroot recipes
│   └── Config.in                     # Buildroot extension config
├── scripts/                          # Helper scripts
│   ├── add-to-path.sh                # Add toolchain to PATH
│   ├── quick-start.sh                # Interactive quick start
│   └── verify-toolchain.sh           # Verify toolchain installation
├── buildroot/                        # Buildroot source (created)
├── crosstool-ng/                     # Crosstool-NG source (created)
└── crosstool-build/                  # CT-NG build directory (created)
```

---

## Performance Tips

### Speed Up Builds
```bash
# Use all available CPU cores
make -j$(nproc) all

# Buildroot: Enable parallel downloads
make BR2_DL_TIMEOUT=60 -j4 all
```

### Reduce Disk Usage
```bash
# Remove build artifacts after successful build
make clean
rm -rf buildroot/dl/*

# Keep only the final toolchain
```

### Cache Management
```bash
# Buildroot caches downloaded packages
# Location: buildroot/dl/
# Clear to reclaim space: rm -rf buildroot/dl/*

# Crosstool-NG caches
# Location: crosstool-src/
# Clear: rm -rf crosstool-src/*
```

---

## Getting Help

### Built-in Help
```bash
make help              # Show all available commands
make buildroot-info    # Show Buildroot information
make crosstool-info    # Show Crosstool-NG information
```

### Online Resources
- **Buildroot**: https://buildroot.org/docs.html
- **Crosstool-NG**: http://crosstool-ng.github.io/
- **ARM Architecture**: https://developer.arm.com/
- **uClibc**: https://uclibc.org/

### Verification Tools
```bash
make verify-gcc        # Check toolchain installation
make show-config       # Show current configuration
./scripts/verify-toolchain.sh buildroot  # Comprehensive test
```

---

## Quick Reference

| Task | Command |
|------|---------|
| Show help | `make help` |
| Interactive menu | `make menu` |
| Check dependencies | `make check-deps` |
| Build with Buildroot | `make buildroot` |
| Build with CT-NG | `make crosstool-ng` |
| Configure Buildroot | `make buildroot-menuconfig` |
| Configure CT-NG | `make crosstool-menuconfig` |
| Verify installation | `make verify-gcc` |
| Add to PATH | `source scripts/add-to-path.sh buildroot` |
| Clean | `make clean` |
| Full cleanup | `make distclean` |

---

## Support

For issues or questions, refer to:
1. This guide (GUIDE.md)
2. README.md
3. Makefile (contains detailed comments)
4. Official project documentation (links above)

Good luck with your Rockchip830 development!
