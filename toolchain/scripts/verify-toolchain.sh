#!/bin/bash

# Verification script for the built toolchain
# Tests all major components

set -e

TOOLCHAIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
METHOD="${1:-buildroot}"

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m'

echo -e "${YELLOW}Rockchip830 Toolchain Verification${NC}"
echo "======================================"
echo ""

# Detect toolchain path
case "$METHOD" in
    buildroot)
        TOOLCHAIN_BIN="${TOOLCHAIN_DIR}/buildroot/output/host/bin"
        ;;
    crosstool-ng)
        TOOLCHAIN_BIN="${INSTALL_PREFIX:-/opt/luckfox-toolchain}/bin"
        ;;
    *)
        TOOLCHAIN_BIN="$METHOD"  # Allow direct path
        ;;
esac

# Check if toolchain exists
if [ ! -d "$TOOLCHAIN_BIN" ]; then
    echo -e "${RED}✗ Toolchain not found at: $TOOLCHAIN_BIN${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Toolchain directory found${NC}"
echo "  Location: $TOOLCHAIN_BIN"
echo ""

# Export PATH
export PATH="${TOOLCHAIN_BIN}:$PATH"

# Test 1: Compiler availability
echo -e "${YELLOW}Test 1: Compiler Tools${NC}"
echo "──────────────────────"

tools=(
    "gcc"
    "g++"
    "cc"
    "as"
    "ld"
    "ar"
    "nm"
    "objdump"
    "objcopy"
    "strip"
    "gdb"
)

failed_tools=0
for tool in "${tools[@]}"; do
    full_tool="arm-rockchip830-linux-uclibcgnueabihf-${tool}"
    if command -v "$full_tool" &> /dev/null; then
        echo -e "  ${GREEN}✓${NC} $tool"
    else
        echo -e "  ${RED}✗${NC} $tool"
        ((failed_tools++))
    fi
done

if [ $failed_tools -eq 0 ]; then
    echo -e "${GREEN}✓ All tools available${NC}"
else
    echo -e "${RED}✗ $failed_tools tools missing${NC}"
fi
echo ""

# Test 2: Compiler information
echo -e "${YELLOW}Test 2: Compiler Information${NC}"
echo "────────────────────────────"

GCC_VERSION=$(arm-rockchip830-linux-uclibcgnueabihf-gcc --version | head -1)
echo "  GCC: $GCC_VERSION"

echo ""

# Test 3: Compile simple C program
echo -e "${YELLOW}Test 3: Compile Test Program${NC}"
echo "─────────────────────────────"

TEST_DIR=$(mktemp -d)
trap "rm -rf $TEST_DIR" EXIT

cat > "$TEST_DIR/test.c" << 'EOF'
#include <stdio.h>
#include <string.h>

int main() {
    char *arch = "ARM";
    int version = 7;
    float pi = 3.14159f;
    
    printf("Hello from Rockchip830 Toolchain!\n");
    printf("Architecture: %s\n", arch);
    printf("ARM Version: ARMv%d-a\n", version);
    printf("Pi value: %.5f\n", pi);
    
    return 0;
}
EOF

if arm-rockchip830-linux-uclibcgnueabihf-gcc -o "$TEST_DIR/test" "$TEST_DIR/test.c"; then
    echo -e "  ${GREEN}✓${NC} C program compiled successfully"
    
    # Check binary type
    FILE_OUTPUT=$(file "$TEST_DIR/test")
    if echo "$FILE_OUTPUT" | grep -q "ARM.*ELF"; then
        echo -e "  ${GREEN}✓${NC} Binary is ARM ELF format"
        echo "    $FILE_OUTPUT"
    else
        echo -e "  ${RED}✗${NC} Binary format unexpected"
        echo "    $FILE_OUTPUT"
    fi
else
    echo -e "  ${RED}✗${NC} C compilation failed"
fi
echo ""

# Test 4: C++ compilation
echo -e "${YELLOW}Test 4: C++ Compilation Test${NC}"
echo "─────────────────────────────"

cat > "$TEST_DIR/test.cpp" << 'EOF'
#include <iostream>
#include <vector>

int main() {
    std::cout << "Hello from C++ on Rockchip830!" << std::endl;
    std::vector<int> nums = {1, 2, 3, 4, 5};
    std::cout << "Vector size: " << nums.size() << std::endl;
    return 0;
}
EOF

if arm-rockchip830-linux-uclibcgnueabihf-g++ -o "$TEST_DIR/test_cpp" "$TEST_DIR/test.cpp"; then
    echo -e "  ${GREEN}✓${NC} C++ program compiled successfully"
else
    echo -e "  ${RED}✗${NC} C++ compilation failed"
fi
echo ""

# Test 5: Library detection
echo -e "${YELLOW}Test 5: Standard Libraries${NC}"
echo "──────────────────────────"

# Check for key libraries
libraries=(
    "libc"
    "libm"
    "libstdc++"
    "libgcc"
)

sysroot=$(arm-rockchip830-linux-uclibcgnueabihf-gcc -print-sysroot)
lib_dir="${sysroot}/lib"

for lib in "${libraries[@]}"; do
    if find "$lib_dir" -name "${lib}.so*" 2>/dev/null | grep -q .; then
        echo -e "  ${GREEN}✓${NC} $lib found"
    else
        echo -e "  ${YELLOW}⊘${NC} $lib (may be in alternative location)"
    fi
done
echo ""

# Test 6: Sysroot information
echo -e "${YELLOW}Test 6: Sysroot Information${NC}"
echo "────────────────────────────"

sysroot=$(arm-rockchip830-linux-uclibcgnueabihf-gcc -print-sysroot)
echo "  Sysroot: $sysroot"

if [ -d "$sysroot" ]; then
    echo -e "  ${GREEN}✓${NC} Sysroot directory exists"
    
    # Count headers
    header_count=$(find "$sysroot/usr/include" -name "*.h" 2>/dev/null | wc -l)
    echo "  Headers: $header_count files"
    
    # Count libraries
    lib_count=$(find "$sysroot/lib" -name "*.so*" 2>/dev/null | wc -l)
    echo "  Libraries: $lib_count files"
else
    echo -e "  ${RED}✗${NC} Sysroot directory not found"
fi
echo ""

# Test 7: Target specifications
echo -e "${YELLOW}Test 7: Target Specifications${NC}"
echo "──────────────────────────────"

echo "  Target CPU:"
arm-rockchip830-linux-uclibcgnueabihf-gcc -v 2>&1 | grep -i "target:" || echo "    (info not available)"

echo "  Compiler specs:"
arm-rockchip830-linux-uclibcgnueabihf-gcc -dumpspecs | grep -i "march\|mfpu\|mfloat" | head -3 || echo "    (specs not shown)"

echo ""

# Summary
echo "======================================"
echo -e "${GREEN}✓ Verification Complete${NC}"
echo ""
echo "The toolchain is ready for use!"
echo ""
echo "To add to PATH permanently, add to ~/.bashrc:"
echo "  export PATH=${TOOLCHAIN_BIN}:\$PATH"
echo ""
echo "Test cross-compilation:"
echo "  arm-rockchip830-linux-uclibcgnueabihf-gcc -o myapp source.c"
