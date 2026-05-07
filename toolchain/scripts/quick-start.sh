#!/bin/bash

# Quick start guide for toolchain build system
# Usage: ./quick-start.sh

clear

echo "╔════════════════════════════════════════════════════════════════╗"
echo "║   Rockchip830 (RV1106) Toolchain Build System - Quick Start   ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""

echo "This script will help you build a cross-compilation toolchain for"
echo "ARM Rockchip830 processors. You have two options:"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Option 1: BUILDROOT (Recommended for most users)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Pros:  Simple, all-in-one, can generate rootfs"
echo "  Cons:  Less granular control"
echo "  Time:  30-45 minutes"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Option 2: CROSSTOOL-NG (For exact control)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Pros:  Exact replication, specialized toolchain builder"
echo "  Cons:  More complex, slower"
echo "  Time:  45-60 minutes"
echo ""

read -p "Select option (1 or 2): " choice

case $choice in
    1)
        echo ""
        echo "You selected: BUILDROOT"
        echo ""
        echo "Prerequisites check..."
        if ! make check-deps; then
            echo ""
            echo "❌ Some dependencies are missing. Please install them first."
            exit 1
        fi
        
        echo ""
        echo "✓ All dependencies available"
        echo ""
        echo "Next steps:"
        echo "  1. Optional: Customize configuration"
        echo "     $ make buildroot-menuconfig"
        echo ""
        echo "  2. Build the toolchain (this will take 30-45 minutes)"
        echo "     $ make buildroot-build"
        echo ""
        echo "  3. Verify installation"
        echo "     $ make verify-gcc"
        echo ""
        echo "  4. Add to PATH (in your shell config)"
        echo "     $ source scripts/add-to-path.sh buildroot"
        echo ""
        read -p "Start build now? (y/n): " start_build
        if [ "$start_build" = "y" ]; then
            make buildroot-build
            echo ""
            echo "✓ Build complete!"
            echo "Add to PATH: source scripts/add-to-path.sh buildroot"
        fi
        ;;
    2)
        echo ""
        echo "You selected: CROSSTOOL-NG"
        echo ""
        echo "Prerequisites check..."
        if ! make check-deps; then
            echo ""
            echo "❌ Some dependencies are missing. Please install them first."
            exit 1
        fi
        
        echo ""
        echo "✓ All dependencies available"
        echo ""
        echo "Next steps:"
        echo "  1. Optional: Customize configuration"
        echo "     $ make crosstool-menuconfig"
        echo ""
        echo "  2. Build the toolchain (this will take 45-60 minutes)"
        echo "     $ make crosstool-build"
        echo ""
        echo "  3. Verify installation"
        echo "     $ make verify-gcc"
        echo ""
        echo "  4. Add to PATH (in your shell config)"
        echo "     $ source scripts/add-to-path.sh crosstool-ng"
        echo ""
        read -p "Start build now? (y/n): " start_build
        if [ "$start_build" = "y" ]; then
            make crosstool-build
            echo ""
            echo "✓ Build complete!"
            echo "Add to PATH: source scripts/add-to-path.sh crosstool-ng"
        fi
        ;;
    *)
        echo "Invalid option"
        exit 1
        ;;
esac

echo ""
echo "For more information, see: README.md"
echo "Or run: make help"
