#!/bin/bash
# Build script for Docker-based ccminer

set -e

echo "Building ccminer Docker image..."
docker-compose build

echo ""
echo "Build complete! You can now run ccminer with:"
echo "  docker-compose up -d          # Run in background"
echo "  docker-compose logs -f        # View logs"
echo "  docker-compose down           # Stop mining"
echo ""
echo "To rebuild after code changes:"
echo "  docker-compose build --no-cache"
