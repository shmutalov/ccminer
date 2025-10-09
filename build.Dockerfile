# Multi-architecture builder for ccminer (Android only)
# Builds for: Android ARM64, Android ARMv7, Android x86_64
# Output: Binaries placed in /output directory (mount this as volume)

# Use pre-built Android NDK image
# Image includes: JDK 17.0.14, NDK 28.0.13004108, CMake 3.31.5
FROM saschpe/android-ndk:35-jdk17.0.14_7-ndk28.0.13004108-cmake3.31.5

# Switch to root to install packages
USER root

# Install build dependencies
RUN apt-get update && apt-get install -y \
    automake \
    autoconf \
    libtool \
    pkg-config \
    git \
    curl \
    libcurl4-openssl-dev \
    libssl-dev \
    ca-certificates \
    file \
    autoconf-archive \
    build-essential \
    libjansson-dev \
    && rm -rf /var/lib/apt/lists/*

# Android NDK is pre-installed in the base image
# The base image sets these paths:
# ANDROID_SDK_ROOT=/opt/android-sdk-linux
# NDK_ROOT=${ANDROID_SDK_ROOT}/ndk/${ndk_version}
ENV ANDROID_NDK_HOME=${NDK_ROOT}
ENV ANDROID_NDK_ROOT=${NDK_ROOT}

# Set up working directory
WORKDIR /build

# Copy source code
COPY . .

WORKDIR ./scripts

# Set entrypoint to build script
ENTRYPOINT ["./build-android-ccminer.sh"]
