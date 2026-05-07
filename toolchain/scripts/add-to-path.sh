#!/bin/bash

# Helper script to add built toolchain to PATH
# Usage: source add-to-path.sh [method]
# method: buildroot or crosstool-ng (default: buildroot)

set -e

TOOLCHAIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
METHOD="${1:-buildroot}"
INSTALL_PREFIX="${INSTALL_PREFIX:-/opt/luckfox-toolchain}"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'

echo -e "${YELLOW}Adding toolchain to PATH...${NC}"

case "$METHOD" in
    buildroot)
        TOOLCHAIN_BIN="${TOOLCHAIN_DIR}/buildroot/output/host/bin"
        if [ ! -d "$TOOLCHAIN_BIN" ]; then
            echo "Error: Buildroot toolchain not found at $TOOLCHAIN_BIN"
            echo "Please run: make buildroot-build"
            return 1
        fi
        ;;
    crosstool-ng)
        TOOLCHAIN_BIN="${INSTALL_PREFIX}/bin"
        if [ ! -d "$TOOLCHAIN_BIN" ]; then
            echo "Error: Crosstool-NG toolchain not found at $TOOLCHAIN_BIN"
            echo "Please run: make crosstool-build"
            return 1
        fi
        ;;
    *)
        echo "Usage: source add-to-path.sh [buildroot|crosstool-ng]"
        return 1
        ;;
esac

# Check if already in PATH
if [[ ":$PATH:" == *":$TOOLCHAIN_BIN:"* ]]; then
    echo -e "${YELLOW}Toolchain already in PATH${NC}"
else
    export PATH="${TOOLCHAIN_BIN}:$PATH"
    echo -e "${GREEN}✓ Added to PATH: $TOOLCHAIN_BIN${NC}"
fi

# Verify
if command -v arm-rockchip830-linux-uclibcgnueabihf-gcc &> /dev/null; then
    echo -e "${GREEN}✓ Toolchain verified${NC}"
    arm-rockchip830-linux-uclibcgnueabihf-gcc --version | head -1
else
    echo "Error: Toolchain not found in PATH"
    return 1
fi
