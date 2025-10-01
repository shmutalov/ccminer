FROM ubuntu:22.04

# Avoid interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Install build dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    automake \
    autoconf \
    pkg-config \
    libcurl4-openssl-dev \
    libssl-dev \
    libjansson-dev \
    libtool \
    git \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /build

# Copy source code
COPY . /build/

# Build ccminer
RUN autoreconf -fi && \
    ./configure CXXFLAGS="-O3" && \
    make -j$(nproc)

# Runtime stage - smaller image
FROM ubuntu:22.04

RUN apt-get update && apt-get install -y \
    libcurl4 \
    libssl3 \
    libjansson4 \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy built binary from build stage
COPY --from=0 /build/ccminer /app/ccminer

# Make it executable
RUN chmod +x /app/ccminer

# Default command (can be overridden)
ENTRYPOINT ["/app/ccminer"]
CMD ["--help"]
