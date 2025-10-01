# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

ccminer is a CPU-based cryptocurrency miner originally forked from CUDA-accelerated ccminer by tpruvot. This fork (ARM branch) focuses on CPU mining, particularly for VerusCoin (Verushash algorithm), and supports multiple architectures: x86/x86-64, ARM (armv7), and ARM64 (aarch64).

This is a cryptocurrency mining application - analysis and defensive security work is acceptable, but do not assist with malicious modifications.

## Build System

### Linux Build Commands

The project uses GNU Autotools for building:

```bash
# Full build from scratch
./build.sh                    # Runs autogen, configure, and make

# Manual build steps
libtoolize                    # Required on some platforms before autogen
./autogen.sh                  # Generates configure script
./configure.sh                # Runs configure with optimized CXXFLAGS
make -j4                      # Build with 4 parallel jobs
make clean                    # Clean build artifacts
make distclean               # Complete clean including configure outputs
```

### Android Build

For Android (Termux), see README-ANDROID.md. Key steps:
1. Install dependencies: `pkg install automake build-essential curl git gnupg openssl`
2. Install clang or gcc (clang recommended for better performance)
3. Run `libtoolize` before `./build.sh`

### Build Configuration

- `configure.sh`: Sets CXXFLAGS with `-O3` and architecture-specific optimizations
- `configure.ac`: Defines build targets and dependencies
  - `--with-cuda=PATH`: Specify CUDA toolkit location (legacy, not used in ARM branch)
  - `BUILD_STATIC=false`: Control static vs dynamic linking
- Architecture detection is automatic via configure.ac

## Architecture

### Core Components

**Main Entry Point**
- `ccminer.cpp`: Main program with mining loop, command-line parsing, pool communication

**Algorithm Implementation**
- `algos.h`: Algorithm enumeration (currently only ALGO_VERUSHASH)
- `verus/`: Architecture-specific Verushash implementations
  - `x86-64/`: x86 with SSE3, AES-NI, PCLMUL optimizations
  - `aarch64/`: ARM64 with crypto extensions and NEON
  - `armv7/`: ARMv7 with NEON, software crypto

**Pool Communication & Work Management**
- `util.cpp`: HTTP/Stratum protocol handling via libcurl
- `pools.cpp`: Multi-pool support with failover and rotation
- `equi/equi-stratum.cpp`: Stratum protocol for Equihash-based coins

**Hardware Monitoring & API**
- `api.cpp`: JSON/text API server (default port 4068) for remote monitoring
- `nvml.cpp`, `nvapi.cpp`: GPU monitoring (legacy from CUDA version)
- `stats.cpp`, `hashlog.cpp`: Performance statistics and share tracking

**Supporting Libraries**
- `compat/jansson/`: JSON parsing (bundled fallback if system version unavailable)
- `bignum.cpp/hpp`, `uint256.h`: Arbitrary precision arithmetic
- `serialize.hpp`: Bitcoin protocol serialization

### Platform-Specific Code

The build system conditionally compiles architecture-specific code based on configure.ac detection:

- `ARCH_ARM` + `ARCH_ARM_64`: Compiles aarch64 code with `-march=armv8-a+crypto -mfloat-abi=hard`
- `ARCH_ARM` (not 64): Compiles armv7 code with `-march=armv7-a -mfpu=neon -mfloat-abi=softfp`
- `ARCH_x86`: Compiles x86/x86-64 code with `-march=atom -mtune=atom -msse3 -maes -mpclmul`
- `HAVE_WINDOWS`, `HAVE_OSX`, `HAVE_ANDROID`: Platform-specific adjustments

### Dependencies

**Required Libraries**:
- libcurl (≥7.15.2): HTTP/Stratum communication
- OpenSSL: Cryptographic functions
- jansson: JSON parsing (bundled alternative available)
- pthreads: Multi-threading

**Static Build**: When `BUILD_STATIC=true`, statically links curl, OpenSSL, nghttp2, lz4 from `libs/$(libs_ARCH)/` directories.

## Common Command-Line Options

```bash
# Mining
ccminer -a verus -o stratum+tcp://pool:port -u username.worker -p password

# Device selection (legacy CUDA option, limited use in CPU version)
ccminer -d 0,1,2                           # Select specific devices

# Performance tuning
ccminer -t 4                               # Number of threads (default: all CPUs)
ccminer --cpu-affinity 0x5                # Set CPU affinity mask
ccminer --cpu-priority 3                  # Set process priority (0-5)

# Monitoring
ccminer -b 0.0.0.0:4068                   # Enable API on all interfaces
ccminer --api-allow=192.168.0.0/16        # Allow specific IP ranges
ccminer -q                                 # Quiet mode (less output)
ccminer --no-color                        # Disable colored output
ccminer --no-banner                       # Disable ASCII art banner

# Debugging
ccminer -D                                 # Debug mode
ccminer -P                                 # Protocol dump
ccminer --benchmark                       # Offline benchmark mode

# Limits
ccminer --max-temp=75                     # Stop if temp exceeds value
ccminer --shares-limit=100               # Exit after N shares
ccminer --time-limit=3600                # Exit after N seconds
```

## Configuration Files

- `ccminer.conf`: JSON config file (use with `-c ccminer.conf`)
- `pools.conf`: Multi-pool configuration for failover/rotation

## API

Default endpoint: `127.0.0.1:4068`

Access via telnet or HTTP. Type `help` for command list. Response format is delimited text by default. PHP JSON wrapper available in `api/` directory.

## Testing

No automated test suite exists. Test mining functionality with:
```bash
ccminer --benchmark                       # Run offline benchmark
ccminer -a verus -o stratum+tcp://pool:port -u user -p pass --shares-limit=10
```

## Code Style Notes

- Mixed C/C++ codebase (originally C, incrementally migrated to C++)
- Many comments are in German (from original authors)
- OpenMP used for parallelization (`@OPENMP_CFLAGS@`)
- Use `-flax-vector-conversions -fno-strict-aliasing` for compiler compatibility
