# Docker Build for ccminer

This Docker setup allows you to build and run ccminer on Linux x86_64 without rebuilding the Android APK.

## Quick Start

### 1. Build the Docker image

```bash
chmod +x build-docker.sh
./build-docker.sh
```

Or manually:
```bash
docker-compose build
```

### 2. Run ccminer

```bash
# Run in background
docker-compose up -d

# View logs
docker-compose logs -f

# Stop mining
docker-compose down
```

### 3. Customize mining parameters

Edit `docker-compose.yml` and modify the `command` section:

```yaml
command: >
  -a verus
  -o stratum+tcp://your-pool:port
  -u your-wallet.worker-name
  -p x
  -t 4                          # Number of threads
```

## Rebuild after code changes

```bash
# Quick rebuild
docker-compose build

# Force full rebuild (no cache)
docker-compose build --no-cache

# Restart after rebuild
docker-compose down
docker-compose up -d
```

## Useful commands

```bash
# View real-time logs
docker-compose logs -f ccminer

# Check if mining
docker-compose ps

# Run one-time command
docker-compose run --rm ccminer --benchmark

# Access container shell
docker-compose run --rm ccminer /bin/bash

# Build specific architecture (x86_64)
docker build -t ccminer:x86_64 .
```

## Troubleshooting

### Build fails with "autogen.sh not found"
Make sure you're running from the ccminer root directory.

### Connection errors
Check your pool URL and wallet address in `docker-compose.yml`.

### Low hashrate
Increase thread count with `-t` parameter or remove CPU limits in docker-compose.yml.

### View detailed debug output
Add `-D -P` to the command in docker-compose.yml for debug and protocol dump.

## Architecture support

This Dockerfile builds for x86_64 Linux. For ARM testing, you can use:

```bash
# Build for ARM64 (if on ARM host or using buildx)
docker buildx build --platform linux/arm64 -t ccminer:arm64 .
```
