**How to compile on Android**

There are two methods (or more?), to compile `ccminer` on Android:

1. By installing a Linux distribution with help of `Termux` + `proot-distro`: https://medium.com/veruscoin/mining-veruscoin-on-smartphone-208dbb06905f
2. By compiling without the any Linux distribution, purely on the system. 

This document explains the second way.

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

# Buy me a beer

Verus address: `RKE5YdseSU6becMtpHKn4z9N4ahRkqm1cV`