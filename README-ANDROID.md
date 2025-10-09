**How to compile on Android**

There are three methods to compile `ccminer` on Android:

1. By installing a Linux distribution with help of `Termux` + `proot-distro`: https://medium.com/veruscoin/mining-veruscoin-on-smartphone-208dbb06905f
2. By compiling without any Linux distribution, purely on the system (native Termux build).
3. By using Docker to build Android binaries on any host system (Linux, Windows, macOS).

This document explains the second and third methods.

*NOTE: Tested on:*
+ rooted Letv Le 1s, Android 6, Mediatek MT6795T
+ unrooted Coolpad Cool1, Android 6, Snapdragon 652
+ unrooted Huawei Honor 9 Lite, Android 9, HiSilicon Kirin 659
+ unrooted Google Android x86-64 emulator, Android 10

# Step 1 - Install the Termux

Download and install the [Termux](https://play.google.com/store/apps/details?id=com.termux) application.
Open the Termux after install. Next steps we need to do inside it.

# Step 2 - Install the dependency packages

Run following command, to install the development dependencies:

`pkg install automake build-essential curl git gnupg openssl nano`

# Step 3 - Install a C/C++ compiler

There are two compilers that can do the work - `clang` (step 3.a) and `gcc` (step 3.b), you can install both, or single one. 
I tested build on both, and `clang` seems produce more performant executable.

## Step 3.a - Install a Clang

We need to use [Its-Pointless Termux repo](https://github.com/its-pointless/gcc_termux), to install latest `clang` from it.

Run the following command, to set-up _Its-Pointless Termux Repo_:

`curl -s https://its-pointless.github.io/setup-pointless-repo.sh | bash`

Then we need to install `clang` package:

`pkg install clang`

To build `ccminer` from sources we need to switch the default `clang` compiler to the latest `clang` we installed by executing following commands:

`setupclang`

## Step 3.b - Install a GCC 

I can't build the `ccminer` with `clang` that default compiler which comes with `Termux` (and Termux makes `clang` as alias for `gcc`). 
Also, Termux deprecated a _real_ gcc compiler tools, so we need to use [Its-Pointless Termux repo](https://github.com/its-pointless/gcc_termux), to install gcc from it.

Run the following command, to set-up _Its-Pointless Termux Repo_:

`curl -s https://its-pointless.github.io/setup-pointless-repo.sh | bash`

Then we need to install `gcc-10` (or `gcc-6`, `gcc-7`, `gcc-8`, `gcc-9`, it depends on the Android version you are running) package:

`pkg install gcc-10`

(or `pkg install gcc-6`, `pkg install gcc-7`, `pkg install gcc-8`, `pkg install gcc-9`, it depends on the Android version you are running)

To build `ccminer` from sources we need to switch the default `clang` compiler to the `gcc` we installed by executing following commands:

`setupgcc-10`

(or `setupgcc-6`, `setupgcc-7`, `setupgcc-8`, `setupgcc-9`)

and then (to make `configure` process happy)

`setup-patchforgcc`

# Step 4 - Build

Clone the `ccminer` git repo (`ARM` branch):

`git clone --single-branch -b ARM https://github.com/shmutalov/ccminer.git`

Then change the current directory:

`cd ccminer`

Run the `libtoolize`:

`libtoolize`

Then start the build:

`./build.sh`

After successful build you can run built `ccminer` binary file to start the mining

# Method 3: Docker Build (Cross-platform)

This method allows you to build Android binaries for all architectures (ARM64, ARMv7, x86_64) on any system with Docker installed. **No need to configure the build environment** - Docker handles all dependencies automatically.

## Prerequisites

- Docker installed and running on your system
  - Windows: [Docker Desktop](https://www.docker.com/products/docker-desktop)
  - Linux: Docker CE/EE
  - macOS: [Docker Desktop](https://www.docker.com/products/docker-desktop)

## Build Steps

### On Windows

Run the batch script:

```cmd
build-android-binaries-with-docker.bat
```

Options:
```cmd
build-android-binaries-with-docker.bat -h              # Show help
build-android-binaries-with-docker.bat -o .\dist      # Custom output directory
build-android-binaries-with-docker.bat -c             # Clean before build
build-android-binaries-with-docker.bat -n             # No Docker cache
```

### On Linux/macOS

Make the script executable and run it:

```bash
chmod +x build-android-binaries-with-docker.sh
./build-android-binaries-with-docker.sh
```

Options:
```bash
./build-android-binaries-with-docker.sh -h              # Show help
./build-android-binaries-with-docker.sh -o ./dist      # Custom output directory
./build-android-binaries-with-docker.sh -c             # Clean before build
./build-android-binaries-with-docker.sh -n             # No Docker cache
```

## Output

Built binaries are automatically copied to the `build-output` directory with the following structure:

```
build-output/
├── arm64-v8a/
│   └── ccminer
├── armeabi-v7a/
│   └── ccminer
└── x86_64/
    └── ccminer
```

Each subdirectory contains the `ccminer` binary optimized for the respective architecture.

## Advantages

- **No configuration required**: All dependencies are handled by Docker
- **Consistent builds**: Same Docker image produces identical results on any platform
- **Multi-architecture**: Builds for all Android architectures in one run
- **Clean environment**: Isolated build environment doesn't affect your system
- **Cross-platform**: Works on Windows, Linux, and macOS

# Buy me a beer

Verus address: `RKE5YdseSU6becMtpHKn4z9N4ahRkqm1cV`