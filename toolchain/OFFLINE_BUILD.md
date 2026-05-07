# OFFLINE_BUILD.md - Using Pre-Downloaded Archives

## Overview

The toolchain build system now supports **offline builds** using pre-downloaded archive files. This eliminates network dependencies and significantly speeds up the setup process.

---

## Pre-Downloaded Archives

The system uses these pre-downloaded archives from the `sources/` directory:

| Archive | Size | Location | Purpose |
|---------|------|----------|---------|
| **buildroot-2023.11.tar.xz** | 5.3M | `sources/buildroot-2023.11.tar.xz` | Buildroot stable release |
| **crosstool-ng-crosstool-ng-1.28.0.zip** | 6.5M | `sources/crosstool-ng-crosstool-ng-1.28.0.zip` | Crosstool-NG toolchain builder |

---

## Benefits of Offline Builds

✅ **No Network Required**
- Build completely offline
- No git cloning needed
- No external downloads during build

✅ **Faster Setup**
- Extraction from local archives (~few seconds)
- No waiting for network transfers
- Instant availability

✅ **Reproducible Builds**
- Same archives always produce same results
- No version changes between builds
- Consistent environments

✅ **Reliable**
- No network timeouts
- No version conflicts
- Predictable extraction

---

## Quick Start

### 1. Verify Archives Are Present
```bash
cd ~/apps/Luckfox_Development/toolchain
make check-sources
```

Expected output:
```
✓ buildroot-2023.11.tar.xz found
✓ crosstool-ng-crosstool-ng-1.28.0.zip found
```

### 2. Build with Buildroot
```bash
make buildroot
# Uses buildroot-2023.11.tar.xz from sources/
```

### 3. Build with Crosstool-NG
```bash
make crosstool-ng
# Uses crosstool-ng-crosstool-ng-1.28.0.zip from sources/
```

---

## Archive Details

### Buildroot Archive
- **File**: `buildroot-2023.11.tar.xz`
- **Size**: 5.3 MB (compressed)
- **Contains**: Buildroot 2023.11 stable release
- **Extracted to**: `buildroot/` directory
- **Extraction**: `tar xf sources/buildroot-2023.11.tar.xz`

### Crosstool-NG Archive
- **File**: `crosstool-ng-crosstool-ng-1.28.0.zip`
- **Size**: 6.5 MB (compressed)
- **Contains**: Crosstool-NG 1.28.0 release
- **Extracted to**: `crosstool-ng/` directory
- **Extraction**: `unzip -q sources/crosstool-ng-crosstool-ng-1.28.0.zip`

---

## Setup Process

### Buildroot Setup (`make buildroot-setup`)
1. Checks if `buildroot/` directory exists
2. If not, looks for `sources/buildroot-2023.11.tar.xz`
3. Extracts archive using `tar`
4. Renames extracted directory from `buildroot-2023.11/` to `buildroot/`
5. Creates `buildroot-output/` directory for build outputs

### Crosstool-NG Setup (`make crosstool-setup`)
1. Checks if `crosstool-ng/` directory exists
2. If not, looks for `sources/crosstool-ng-crosstool-ng-1.28.0.zip`
3. Extracts archive using `unzip`
4. Renames extracted directory from `crosstool-ng-crosstool-ng-1.28.0/` to `crosstool-ng/`
5. Runs bootstrap, configure, make, make install
6. Creates `crosstool-build/` and `crosstool-src/` directories

---

## Troubleshooting

### "Archive not found" Error

**Error message**:
```
Error: sources/buildroot-2023.11.tar.xz not found
```

**Solution**: 
Verify the archive file exists:
```bash
make check-sources
```

If archives are missing, download them:

**Buildroot**:
```bash
cd ~/apps/Luckfox_Development/toolchain/sources
wget https://git.buildroot.net/buildroot/snapshot/buildroot-2023.11.tar.xz
```

**Crosstool-NG**:
```bash
cd ~/apps/Luckfox_Development/toolchain/sources
wget https://github.com/crosstool-ng/crosstool-ng/archive/refs/tags/crosstool-ng-1.28.0.zip
```

### "tar: command not found"

**Solution**:
Install tar utility:
```bash
# Ubuntu/Debian
sudo apt-get install tar

# RHEL/CentOS
sudo yum install tar
```

### "unzip: command not found"

**Solution**:
Install unzip utility:
```bash
# Ubuntu/Debian
sudo apt-get install unzip

# RHEL/CentOS
sudo yum install unzip
```

---

## Manual Archive Management

### Check Archive Integrity
```bash
cd ~/apps/Luckfox_Development/toolchain/sources

# List contents without extracting
tar -tf buildroot-2023.11.tar.xz | head
unzip -l crosstool-ng-crosstool-ng-1.28.0.zip | head
```

### Manual Extraction
```bash
cd ~/apps/Luckfox_Development/toolchain

# Buildroot
tar xf sources/buildroot-2023.11.tar.xz
mv buildroot-2023.11 buildroot

# Crosstool-NG
unzip -q sources/crosstool-ng-crosstool-ng-1.28.0.zip
mv crosstool-ng-crosstool-ng-1.28.0 crosstool-ng
```

### Re-extract After Cleanup
```bash
# Remove extracted directories
rm -rf buildroot crosstool-ng

# Re-extract from archives
make buildroot-setup    # For buildroot
make crosstool-setup    # For crosstool-ng
```

---

## Offline Development Workflow

### Complete Offline Build

1. **Prepare** (requires internet once):
   ```bash
   # Download archives to sources/
   cd ~/apps/Luckfox_Development/toolchain/sources
   wget https://git.buildroot.net/buildroot/snapshot/buildroot-2023.11.tar.xz
   wget https://github.com/crosstool-ng/crosstool-ng/archive/refs/tags/crosstool-ng-1.28.0.zip
   ```

2. **Transport** (no internet needed):
   - Copy entire `toolchain/` directory to offline machine
   - Move to development environment

3. **Build** (completely offline):
   ```bash
   cd ~/apps/Luckfox_Development/toolchain
   make check-deps         # Verify local tools
   make check-sources      # Verify archives present
   make buildroot          # Build toolchain (no network)
   ```

### Benefits in Restricted Networks
- Build in airgapped environments
- No firewall/proxy configuration needed
- No corporate network restrictions
- Complete transparency - all sources local

---

## Archive File Locations

```
toolchain/
├── sources/
│   ├── buildroot-2023.11.tar.xz           (5.3M)
│   └── crosstool-ng-crosstool-ng-1.28.0.zip  (6.5M)
├── buildroot/                             (extracted)
├── crosstool-ng/                          (extracted)
├── Makefile
├── README.md
└── ...
```

---

## Commands Summary

| Command | Purpose | Archives Used |
|---------|---------|---------------|
| `make check-sources` | Verify archives present | Both |
| `make buildroot-setup` | Extract buildroot | Buildroot |
| `make crosstool-setup` | Extract crosstool-ng | Crosstool-NG |
| `make buildroot` | Full buildroot build | Buildroot |
| `make crosstool-ng` | Full crosstool-ng build | Crosstool-NG |
| `make clean` | Remove build artifacts | None |
| `make distclean` | Remove builds (keep archives) | None |

---

## Notes

- **Archives are preserved** - `make distclean` does NOT delete `sources/` directory
- **No git required** - Git is not needed with pre-downloaded archives
- **Fast extraction** - Both archives extract in seconds
- **Idempotent** - Running setup multiple times is safe (skips if already extracted)

---

## Related Documentation

- **README.md** - Project overview
- **GUIDE.md** - Complete build guide
- **CHANGES.md** - What's new
- **Makefile** - Build system commands
