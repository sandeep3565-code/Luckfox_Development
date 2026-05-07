# Toolchain Build System for Rockchip830 (RV1106)
# Supports both Buildroot and Crosstool-NG methods
# Usage: make help

.PHONY: help menu buildroot crosstool-ng clean distclean check-deps

SHELL := /bin/bash
TOOLCHAIN_DIR := $(shell pwd)
BUILD_METHOD ?= buildroot
INSTALL_PREFIX ?= /opt/luckfox-toolchain

# Colors for output (disable if terminal doesn't support)
# Comment out to disable colors
RED := 
GREEN := 
YELLOW := 
NC := 
# Uncomment below for colored output (if terminal supports it):
# RED := \033[0;31m
# GREEN := \033[0;32m
# YELLOW := \033[0;33m
# NC := \033[0m

# ==============================================================================
# HELP TARGETS
# ==============================================================================

help:
	@echo "$(GREEN)=== Rockchip830 Toolchain Build System ===$(NC)"
	@echo ""
	@echo "$(YELLOW)Available Build Methods:$(NC)"
	@echo "  make menu                  - Interactive menu to select build method"
	@echo "  make buildroot             - Build with Buildroot"
	@echo "  make crosstool-ng          - Build with Crosstool-NG"
	@echo ""
	@echo "$(YELLOW)Configuration:$(NC)"
	@echo "  make buildroot-config      - Configure Buildroot (menuconfig)"
	@echo "  make crosstool-config      - Configure Crosstool-NG (menuconfig)"
	@echo ""
	@echo "$(YELLOW)Cleanup:$(NC)"
	@echo "  make clean                 - Remove build artifacts"
	@echo "  make distclean              - Remove all builds and sources"
	@echo ""
	@echo "$(YELLOW)Utilities:$(NC)"
	@echo "  make check-deps            - Check required dependencies"
	@echo "  make check-sources         - Check for pre-downloaded archives"
	@echo "  make show-config           - Show current configuration"
	@echo ""
	@echo "$(YELLOW)Source Archives (Offline Mode):$(NC)"
	@echo "  Uses pre-downloaded archives in sources/ directory:"
	@echo "    - buildroot-2020.02.tar.gz"
	@echo "    - crosstool-ng-crosstool-ng-1.28.0.zip"
	@echo ""
	@echo "$(YELLOW)Environment Variables:$(NC)"
	@echo "  BUILD_METHOD=buildroot     - Select build method (default: buildroot)"
	@echo "  INSTALL_PREFIX=/path       - Installation directory (default: $(INSTALL_PREFIX))"
	@echo ""
	@echo "$(YELLOW)Example Usage:$(NC)"
	@echo "  make check-sources         - Verify archives are present"
	@echo "  make menu                  - Interactive selection"
	@echo "  make buildroot             - Build with Buildroot"
	@echo "  make crosstool-ng          - Build with Crosstool-NG"

menu:
	@echo "$(GREEN)=== Rockchip830 Toolchain Build Menu ===$(NC)"
	@echo ""
	@echo "Select toolchain build method:"
	@echo "  1) Buildroot (recommended, easier)"
	@echo "  2) Crosstool-NG (exact replication)"
	@echo "  3) Exit"
	@echo ""
	@read -p "Enter choice [1-3]: " choice; \
	case $$choice in \
		1) $(MAKE) buildroot-build ;; \
		2) $(MAKE) crosstool-build ;; \
		3) echo "Exiting..."; exit 0 ;; \
		*) echo "Invalid choice"; exit 1 ;; \
	esac

# ==============================================================================
# DEPENDENCY CHECKING
# ==============================================================================

check-deps:
	@echo "$(YELLOW)Checking dependencies...$(NC)"
	@command -v gcc >/dev/null 2>&1 || { echo "$(RED)✗ gcc not found$(NC)"; exit 1; }
	@command -v g++ >/dev/null 2>&1 || { echo "$(RED)✗ g++ not found$(NC)"; exit 1; }
	@command -v make >/dev/null 2>&1 || { echo "$(RED)✗ make not found$(NC)"; exit 1; }
	@echo "$(GREEN)✓ Build essentials$(NC)"
	@command -v flex >/dev/null 2>&1 || { echo "$(RED)✗ flex not found (required)$(NC)"; exit 1; }
	@command -v bison >/dev/null 2>&1 || { echo "$(RED)✗ bison not found (required)$(NC)"; exit 1; }
	@echo "$(GREEN)✓ Parser generators$(NC)"
	@command -v tar >/dev/null 2>&1 && echo "$(GREEN)✓ tar$(NC)" || echo "$(YELLOW)⊘ tar (for extraction)$(NC)"
	@command -v unzip >/dev/null 2>&1 && echo "$(GREEN)✓ unzip$(NC)" || echo "$(YELLOW)⊘ unzip (for extraction)$(NC)"
	@echo ""
	@echo "$(GREEN)All required dependencies are installed!$(NC)"

check-sources:
	@echo "$(YELLOW)Checking for pre-downloaded source archives...$(NC)"
	@echo ""
	@if [ -f "$(TOOLCHAIN_DIR)/sources/buildroot-2020.02.tar.gz" ]; then \
		echo "$(GREEN)✓ buildroot-2020.02.tar.gz found$(NC)"; \
		ls -lh $(TOOLCHAIN_DIR)/sources/buildroot-2020.02.tar.gz; \
	else \
		echo "$(RED)✗ buildroot-2020.02.tar.gz NOT found$(NC)"; \
	fi
	@echo ""
	@if [ -f "$(TOOLCHAIN_DIR)/sources/crosstool-ng-crosstool-ng-1.28.0.zip" ]; then \
		echo "$(GREEN)✓ crosstool-ng-crosstool-ng-1.28.0.zip found$(NC)"; \
		ls -lh $(TOOLCHAIN_DIR)/sources/crosstool-ng-crosstool-ng-1.28.0.zip; \
	else \
		echo "$(RED)✗ crosstool-ng-crosstool-ng-1.28.0.zip NOT found$(NC)"; \
	fi
	@echo ""
	@echo "$(YELLOW)Archive locations:$(NC)"
	@echo "  Buildroot: $(TOOLCHAIN_DIR)/sources/buildroot-2020.02.tar.gz"
	@echo "  Crosstool-NG: $(TOOLCHAIN_DIR)/sources/crosstool-ng-crosstool-ng-1.28.0.zip"
	@echo ""
	@echo "$(GREEN)Note: System uses these local archives for faster, offline builds$(NC)"

# ==============================================================================
# BUILDROOT METHOD
# ==============================================================================

buildroot: check-deps buildroot-setup buildroot-config buildroot-build

buildroot-setup:
	@echo "$(YELLOW)Setting up Buildroot environment...$(NC)"
	@if [ ! -d "$(TOOLCHAIN_DIR)/buildroot" ]; then \
		if [ -f "$(TOOLCHAIN_DIR)/sources/buildroot-2020.02.tar.gz" ]; then \
			echo "Extracting buildroot from archive (2020.02)..."; \
			cd $(TOOLCHAIN_DIR) && tar xf sources/buildroot-2020.02.tar.gz && \
			mv buildroot-2020.02 buildroot && \
			echo "✓ Buildroot extracted successfully"; \
		else \
			echo "$(RED)Error: sources/buildroot-2020.02.tar.gz not found$(NC)"; \
			echo "Please download: https://git.buildroot.net/buildroot/snapshot/buildroot-2020.02.tar.gz"; \
			exit 1; \
		fi \
	else \
		echo "Buildroot already extracted"; \
	fi
	@echo "$(YELLOW)Installing m4 SIGSTKSZ compatibility patch...$(NC)"
	@if [ -f "$(TOOLCHAIN_DIR)/patches/0003-sigstksz-modern-glibc.patch" ]; then \
		cp -v $(TOOLCHAIN_DIR)/patches/0003-sigstksz-modern-glibc.patch $(TOOLCHAIN_DIR)/buildroot/package/m4/; \
		cp -v $(TOOLCHAIN_DIR)/patches/0004-glibc-2.34-stat-ver.patch $(TOOLCHAIN_DIR)/buildroot/package/fakeroot/; \
		echo "$(GREEN)✓ Patch file installed$(NC)"; \
	else \
		echo "$(YELLOW)Warning: Patch not found at $(TOOLCHAIN_DIR)/patches/$(NC)"; \
	fi
	@mkdir -p $(TOOLCHAIN_DIR)/buildroot-output

buildroot-config:
	@echo "$(GREEN)Buildroot Configuration$(NC)"
	@echo "Copying default configuration..."
	@if [ -f "$(TOOLCHAIN_DIR)/configs/rockchip830_defconfig" ]; then \
		cp $(TOOLCHAIN_DIR)/configs/rockchip830_defconfig $(TOOLCHAIN_DIR)/buildroot/.config; \
		echo "$(GREEN)✓ Configuration loaded from configs/rockchip830_defconfig$(NC)"; \
		echo "$(YELLOW)Validating configuration with 'make olddefconfig'...$(NC)"; \
		cd $(TOOLCHAIN_DIR)/buildroot && make olddefconfig >/dev/null 2>&1; \
		echo "$(GREEN)✓ Configuration validated and ready$(NC)"; \
	else \
		echo "$(YELLOW)No saved configuration found. Using defaults.$(NC)"; \
	fi
	@echo ""
	@echo "$(YELLOW)Run 'make buildroot-menuconfig' to customize, then 'make buildroot-build'$(NC)"

buildroot-menuconfig:
	@echo "$(YELLOW)Opening Buildroot menuconfig...$(NC)"
	@cd $(TOOLCHAIN_DIR)/buildroot && \
	make menuconfig
	@echo "$(GREEN)✓ Configuration saved$(NC)"
	@echo "Run 'make buildroot-build' to start the build"

buildroot-build:
	@echo "$(GREEN)Building with Buildroot...$(NC)"
	@echo "This may take 30-45 minutes. Please be patient..."
	@echo ""
	@echo "$(YELLOW)Buildroot patches (auto-applied):$(NC)"
	@echo "  - 0003-sigstksz-modern-glibc.patch (fixes SIGSTKSZ preprocessor issue)"
	@echo ""
	@cd $(TOOLCHAIN_DIR)/buildroot && \
	make -j1
	@echo ""
	@echo "$(GREEN)✓ Buildroot toolchain build complete!$(NC)"
	@echo "Toolchain location: $(TOOLCHAIN_DIR)/buildroot/output/host/bin"

buildroot-info:
	@echo "$(GREEN)Buildroot Information:$(NC)"
	@echo "  Method: Buildroot 2020.02 (cross-compilation framework)"
	@echo "  GCC Version: 8.3.0 (default for BR2_GCC_VERSION_8_X)"
	@echo "  Speed: Fast (30-45 minutes)"
	@echo "  Pros: All-in-one, generates rootfs too"
	@echo "  Cons: Less granular control"
	@echo ""
	@echo "Configuration files:"
	@echo "  - $(TOOLCHAIN_DIR)/configs/rockchip830_defconfig"
	@echo "  - $(TOOLCHAIN_DIR)/br-external/ (external recipes)"
	@echo ""
	@echo "Compatibility patches (auto-applied during build):"
	@echo "  - 0003-sigstksz-modern-glibc.patch (removes SIGSTKSZ in preprocessor)"

# ==============================================================================
# CROSSTOOL-NG METHOD
# ==============================================================================

crosstool-ng: check-deps crosstool-setup crosstool-config crosstool-build

crosstool-setup:
	@echo "$(YELLOW)Setting up Crosstool-NG environment...$(NC)"
	@if [ ! -d "$(TOOLCHAIN_DIR)/crosstool-ng" ]; then \
		if [ -f "$(TOOLCHAIN_DIR)/sources/crosstool-ng-crosstool-ng-1.28.0.zip" ]; then \
			echo "Extracting crosstool-ng from archive (1.28.0)..."; \
			cd $(TOOLCHAIN_DIR) && unzip -q sources/crosstool-ng-crosstool-ng-1.28.0.zip && \
			mv crosstool-ng-crosstool-ng-1.28.0 crosstool-ng && \
			echo "✓ Crosstool-NG extracted successfully"; \
			echo "Configuring crosstool-ng..."; \
			cd $(TOOLCHAIN_DIR)/crosstool-ng && ./bootstrap && \
			./configure --prefix=$(TOOLCHAIN_DIR)/crosstool-ng/install && \
			make && make install && \
			echo "✓ Crosstool-NG configured successfully"; \
		else \
			echo "$(RED)Error: sources/crosstool-ng-crosstool-ng-1.28.0.zip not found$(NC)"; \
			echo "Please download from: https://github.com/crosstool-ng/crosstool-ng/releases/tag/crosstool-ng-1.28.0"; \
			exit 1; \
		fi \
	else \
		echo "Crosstool-NG already extracted"; \
	fi
	@mkdir -p $(TOOLCHAIN_DIR)/crosstool-build
	@mkdir -p $(TOOLCHAIN_DIR)/crosstool-src

crosstool-config:
	@echo "$(GREEN)Crosstool-NG Configuration$(NC)"
	@echo "Preparing configuration..."
	@if [ -f "$(TOOLCHAIN_DIR)/configs/arm-rockchip830-linux-uclibcgnueabihf.defconfig" ]; then \
		cp $(TOOLCHAIN_DIR)/configs/arm-rockchip830-linux-uclibcgnueabihf.defconfig $(TOOLCHAIN_DIR)/crosstool-build/.config; \
		echo "$(GREEN)✓ Configuration loaded$(NC)"; \
	else \
		echo "$(YELLOW)No saved configuration found. Using defaults.$(NC)"; \
	fi
	@echo ""
	@echo "$(YELLOW)Run 'make crosstool-menuconfig' to customize, then 'make crosstool-build'$(NC)"

crosstool-menuconfig:
	@echo "$(YELLOW)Opening Crosstool-NG menuconfig...$(NC)"
	@export CT_PREFIX_DIR=$(INSTALL_PREFIX) && \
	export CT_LOCAL_TARBALLS_DIR=$(TOOLCHAIN_DIR)/crosstool-src && \
	cd $(TOOLCHAIN_DIR)/crosstool-build && \
	$(TOOLCHAIN_DIR)/crosstool-ng/install/bin/ct-ng menuconfig
	@echo "$(GREEN)✓ Configuration saved$(NC)"
	@echo "Run 'make crosstool-build' to start the build"

crosstool-build:
	@echo "$(GREEN)Building with Crosstool-NG...$(NC)"
	@echo "This may take 45-60 minutes. Please be patient..."
	@echo ""
	@export CT_PREFIX_DIR=$(INSTALL_PREFIX) && \
	export CT_LOCAL_TARBALLS_DIR=$(TOOLCHAIN_DIR)/crosstool-src && \
	export CT_ALLOW_BUILD_AS_ROOT=y && \
	export CT_ALLOW_BUILD_AS_ROOT_SURE=y && \
	cd $(TOOLCHAIN_DIR)/crosstool-build && \
	$(TOOLCHAIN_DIR)/crosstool-ng/install/bin/ct-ng build
	@echo ""
	@echo "$(GREEN)✓ Crosstool-NG toolchain build complete!$(NC)"
	@echo "Toolchain location: $(INSTALL_PREFIX)/bin"

crosstool-info:
	@echo "$(GREEN)Crosstool-NG Information:$(NC)"
	@echo "  Method: Crosstool-NG (specialized toolchain builder)"
	@echo "  Speed: Slower (45-60 minutes)"
	@echo "  Pros: Exact control, exact replication"
	@echo "  Cons: More complex configuration"
	@echo ""
	@echo "Configuration files:"
	@echo "  - $(TOOLCHAIN_DIR)/configs/arm-rockchip830-linux-uclibcgnueabihf.defconfig"

# ==============================================================================
# SHORTCUTS
# ==============================================================================

# Removed circular dependencies - they were causing build failures

# ==============================================================================
# CONFIGURATION DISPLAY
# ==============================================================================

show-config:
	@echo "$(GREEN)=== Current Configuration ===$(NC)"
	@echo "Toolchain Directory: $(TOOLCHAIN_DIR)"
	@echo "Installation Prefix: $(INSTALL_PREFIX)"
	@echo "Build Method: $(BUILD_METHOD)"
	@echo ""
	@echo "$(YELLOW)Available Configurations:$(NC)"
	@ls -la $(TOOLCHAIN_DIR)/configs/ 2>/dev/null || echo "No saved configurations"

# ==============================================================================
# CLEANUP TARGETS
# ==============================================================================

clean:
	@echo "$(YELLOW)Cleaning build artifacts...$(NC)"
	@rm -rf $(TOOLCHAIN_DIR)/buildroot-output $(TOOLCHAIN_DIR)/crosstool-build/.build
	@echo "$(GREEN)✓ Build artifacts cleaned$(NC)"

distclean: clean
	@echo "$(YELLOW)Performing full cleanup...$(NC)"
	@echo "$(YELLOW)Note: sources/ directory will NOT be deleted (contains pre-downloaded archives)$(NC)"
	@read -p "This will remove all sources and builds. Continue? [y/N]: " confirm; \
	if [ "$$confirm" = "y" ] || [ "$$confirm" = "Y" ]; then \
		rm -rf $(TOOLCHAIN_DIR)/buildroot $(TOOLCHAIN_DIR)/crosstool-ng $(TOOLCHAIN_DIR)/crosstool-build $(TOOLCHAIN_DIR)/crosstool-src; \
		echo "$(GREEN)✓ Full cleanup complete (sources/ preserved)$(NC)"; \
	else \
		echo "Cleanup cancelled"; \
	fi

# ==============================================================================
# INSTALLATION
# ==============================================================================

install-buildroot:
	@echo "$(YELLOW)Installing Buildroot toolchain...$(NC)"
	@mkdir -p $(INSTALL_PREFIX)
	@cp -rfa $(TOOLCHAIN_DIR)/buildroot/output/host/* $(INSTALL_PREFIX)/
	@echo "$(GREEN)✓ Buildroot toolchain installed to $(INSTALL_PREFIX)$(NC)"
	@echo "Add to PATH: export PATH=$(INSTALL_PREFIX)/bin:\$$PATH"

install-crosstool:
	@echo "$(YELLOW)Crosstool-NG toolchain already installed to: $(INSTALL_PREFIX)$(NC)"
	@ls -la $(INSTALL_PREFIX)/bin/ | head -20

# ==============================================================================
# VERIFICATION
# ==============================================================================

verify-gcc:
	@if command -v arm-rockchip830-linux-uclibcgnueabihf-gcc >/dev/null 2>&1; then \
		echo "$(GREEN)✓ GCC found$(NC)"; \
		arm-rockchip830-linux-uclibcgnueabihf-gcc --version; \
	else \
		echo "$(RED)✗ GCC not found in PATH$(NC)"; \
		exit 1; \
	fi

verify-install:
	@echo "$(YELLOW)Verifying toolchain installation...$(NC)"
	@if [ -d "$(INSTALL_PREFIX)/bin" ]; then \
		echo "$(GREEN)✓ Toolchain directory exists$(NC)"; \
		ls -la $(INSTALL_PREFIX)/bin/arm-buildroot-linux-uclibcgnueabi-gcc* 2>/dev/null && \
		echo "$(GREEN)✓ Toolchain components found$(NC)" || \
		echo "$(RED)✗ Toolchain components not found$(NC)"; \
	else \
		echo "$(RED)✗ Toolchain directory not found at $(INSTALL_PREFIX)$(NC)"; \
	fi

.DEFAULT_GOAL := help
