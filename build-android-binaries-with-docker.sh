#!/bin/bash
# Build ccminer for Android using Docker
# Builds all Android architectures: ARM64, ARMv7, x86_64

set -e

# Configuration
IMAGE_NAME="ccminer-android-builder"
IMAGE_TAG="latest"
OUTPUT_DIR="./build-output"
CLEAN=false
NO_CACHE=""

# Function to display usage
usage() {
    cat <<EOF

Usage: $(basename "$0") [OPTIONS]

Options:
  -o, --output DIR      Output directory (default: ./build-output)
  -c, --clean           Clean output directory before build
  -n, --no-cache        Build Docker image without cache
  -h, --help            Show this help message

Examples:
  $(basename "$0")                    # Build all Android architectures
  $(basename "$0") -o ./dist         # Use custom output directory
  $(basename "$0") -c                # Clean before build

EOF
    exit 0
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        -o|--output)
            OUTPUT_DIR="$2"
            shift 2
            ;;
        -c|--clean)
            CLEAN=true
            shift
            ;;
        -n|--no-cache)
            NO_CACHE="--no-cache"
            shift
            ;;
        -h|--help)
            usage
            ;;
        *)
            echo "Error: Unknown option: $1"
            usage
            ;;
    esac
done

echo ""
echo "========================================"
echo "  ccminer Android Builder"
echo "========================================"
echo ""

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "Error: Docker is not installed or not running"
    exit 1
fi

# Check if Docker daemon is running
if ! docker info &> /dev/null; then
    echo "Error: Docker daemon is not running"
    exit 1
fi

# Clean output directory if requested
if [ "$CLEAN" = true ]; then
    if [ -d "$OUTPUT_DIR" ]; then
        echo "Cleaning output directory: $OUTPUT_DIR"
        rm -rf "$OUTPUT_DIR"
    fi
fi

# Create output directory
mkdir -p "$OUTPUT_DIR"

# Get absolute path
OUTPUT_DIR=$(cd "$OUTPUT_DIR" && pwd)

echo "Output directory: $OUTPUT_DIR"
echo ""

# Build Docker image
echo "[1/2] Building Docker image..."
docker build $NO_CACHE -t "$IMAGE_NAME:$IMAGE_TAG" --progress=plain -f ./build.Dockerfile .

if [ $? -ne 0 ]; then
    echo "Error: Docker image build failed"
    exit 1
fi

echo "SUCCESS: Docker image built successfully"
echo ""

# Run build container with mounted output directory
echo "[2/2] Running build container..."
echo "Building Android binaries for: ARM64, ARMv7, x86_64"
echo ""

docker run --rm -v "$OUTPUT_DIR:/build/output" "$IMAGE_NAME:$IMAGE_TAG"

if [ $? -ne 0 ]; then
    echo "Error: Build failed"
    exit 1
fi

echo ""
echo "========================================"
echo "  Build Complete!"
echo "========================================"
echo ""
echo "Output directory structure:"
echo "$OUTPUT_DIR"

# Display directory tree if tree command is available
if command -v tree &> /dev/null; then
    tree "$OUTPUT_DIR"
else
    find "$OUTPUT_DIR" -type f | sed 's|[^/]*/|  |g'
fi

exit 0
