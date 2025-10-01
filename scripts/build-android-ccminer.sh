#!/bin/bash
#
# Copyright 2016 leenjewel
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# # read -n1 -p "Press any key to continue..."

set -u

source ./build-android-common.sh

init_log_color

TOOLS_ROOT=$(pwd)

SOURCE="$0"
while [ -h "$SOURCE" ]; do
    DIR="$(cd -P "$(dirname "$SOURCE")" && pwd)"
    SOURCE="$(readlink "$SOURCE")"
    [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE"
done
pwd_path="$(cd -P "$(dirname "$SOURCE")" && pwd)"

echo pwd_path=${pwd_path}
echo TOOLS_ROOT=${TOOLS_ROOT}

set_android_toolchain_bin

function configure_make() {

    ARCH=$1
    ABI=$2
    ABI_TRIPLE=$3

    log_info "configure $ABI start..."

    pushd .
    cd ".."

    PREFIX_DIR="${pwd_path}/../output/ccminer-${ABI}"
    if [ -d "${PREFIX_DIR}" ]; then
        rm -fr "${PREFIX_DIR}"
    fi
    mkdir -p "${PREFIX_DIR}"

    OUTPUT_ROOT=${TOOLS_ROOT}/../output/ccminer-${ABI}
    mkdir -p ${OUTPUT_ROOT}/log

    set_android_toolchain "ccminer" "${ARCH}" "${ANDROID_API}"
    set_android_cpu_feature "ccminer" "${ARCH}" "${ANDROID_API}"

    export ANDROID_NDK_HOME=${ANDROID_NDK_ROOT}
    echo ANDROID_NDK_HOME=${ANDROID_NDK_HOME}

    android_printf_global_params "$ARCH" "$ABI" "$ABI_TRIPLE" "$PREFIX_DIR" "$OUTPUT_ROOT"

    make distclean || echo clean

    rm -f Makefile.in
    rm -f config.status

    # Use autoreconf to regenerate all autotools files with consistent versions
    autoreconf -fi || ./autogen.sh

    extracflags="-D_REENTRANT -falign-functions=16 -falign-jumps=16 -falign-labels=16"

    # Android doesn't need -pthread flag, pthreads are in libc (Bionic)
    export ac_cv_search_pthread_create="none required"
    export PTHREAD_FLAGS=""
    export PTHREAD_LIBS=""

    # Remove -pthread from LDFLAGS if present
    export LDFLAGS="${LDFLAGS/-pthread/}"

    if [[ "${ARCH}" == "x86_64" ]]; then

        ./configure --host=$(android_get_build_host "${ARCH}") \
            CFLAGS="${CFLAGS} -O3 $extracflags" \
            CXXFLAGS="${CXXFLAGS} -O3 $extracflags" \
            LDFLAGS="${LDFLAGS}" \
            SHARED_LDFLAGS="" \
            BUILD_STATIC=true --prefix="${PREFIX_DIR}" >"${OUTPUT_ROOT}/log/${ABI}.log" 2>&1

    elif [[ "${ARCH}" == "x86" ]]; then

        ./configure --host=$(android_get_build_host "${ARCH}") \
            CFLAGS="${CFLAGS} -O3 $extracflags" \
            CXXFLAGS="${CXXFLAGS} -O3 $extracflags" \
            LDFLAGS="${LDFLAGS}" \
            SHARED_LDFLAGS="" \
            BUILD_STATIC=true --prefix="${PREFIX_DIR}" >"${OUTPUT_ROOT}/log/${ABI}.log" 2>&1

    elif [[ "${ARCH}" == "arm" ]]; then

        ./configure --host=$(android_get_build_host "${ARCH}") \
            CFLAGS="${CFLAGS} -O3 $extracflags" \
            CXXFLAGS="${CXXFLAGS} -O3 $extracflags" \
            LDFLAGS="${LDFLAGS}" \
            SHARED_LDFLAGS="" \
            BUILD_STATIC=true --prefix="${PREFIX_DIR}" >"${OUTPUT_ROOT}/log/${ABI}.log" 2>&1

    elif [[ "${ARCH}" == "arm64" ]]; then

        ./configure --host=$(android_get_build_host "${ARCH}") \
            CFLAGS="${CFLAGS} -O3 $extracflags" \
            CXXFLAGS="${CXXFLAGS} -O3 $extracflags" \
            LDFLAGS="${LDFLAGS}" \
            SHARED_LDFLAGS="" \
            BUILD_STATIC=true --prefix="${PREFIX_DIR}" >"${OUTPUT_ROOT}/log/${ABI}.log" 2>&1

    else
        log_error "not support" && exit 1
    fi

    # Copy config.log for debugging
    if [ -f "config.log" ]; then
        cp config.log "${OUTPUT_ROOT}/log/${ABI}-config.log"
    fi

    log_info "make $ABI start..."

    make clean >>"${OUTPUT_ROOT}/log/${ABI}.log"
    if make -j$(get_cpu_count) >>"${OUTPUT_ROOT}/log/${ABI}.log" 2>&1; then
        make install >>"${OUTPUT_ROOT}/log/${ABI}.log" 2>&1

        # Copy required shared libraries to output directory
        log_info "Copying shared libraries for $ABI..."
        TOOLCHAIN=$(get_toolchain)

        # Copy libc++_shared.so
        LIBC_SO_SOURCE="${ANDROID_NDK_ROOT}/toolchains/llvm/prebuilt/${TOOLCHAIN}/sysroot/usr/lib/${ABI_TRIPLE}/libc++_shared.so"
        LIBC_SO_DEST="${PREFIX_DIR}/bin/libc++_shared.so"
        if [ -f "${LIBC_SO_SOURCE}" ]; then
            cp "${LIBC_SO_SOURCE}" "${LIBC_SO_DEST}"
            log_info "Copied libc++_shared.so to ${LIBC_SO_DEST}"
        else
            log_warning "libc++_shared.so not found at ${LIBC_SO_SOURCE}"
        fi

        # Copy libomp.so (architecture-specific)
        LIBOMP_ARCH=""
        case ${ARCH} in
            arm64)
                LIBOMP_ARCH="aarch64"
                ;;
            arm)
                LIBOMP_ARCH="arm"
                ;;
            x86_64)
                LIBOMP_ARCH="x86_64"
                ;;
            x86)
                LIBOMP_ARCH="i386"
                ;;
        esac

        LIBOMP_SO_SOURCE="${ANDROID_NDK_ROOT}/toolchains/llvm/prebuilt/${TOOLCHAIN}/lib/clang/17/lib/linux/${LIBOMP_ARCH}/libomp.so"
        LIBOMP_SO_DEST="${PREFIX_DIR}/bin/libomp.so"
        if [ -f "${LIBOMP_SO_SOURCE}" ]; then
            cp "${LIBOMP_SO_SOURCE}" "${LIBOMP_SO_DEST}"
            log_info "Copied libomp.so to ${LIBOMP_SO_DEST}"
        else
            log_warning "libomp.so not found at ${LIBOMP_SO_SOURCE}"
        fi
    fi

    popd
}

log_info "${PLATFORM_TYPE} ccminer start..."

for ((i = 0; i < ${#ARCHS[@]}; i++)); do
    if [[ $# -eq 0 || "$1" == "${ARCHS[i]}" ]]; then
        configure_make "${ARCHS[i]}" "${ABIS[i]}" "${ABI_TRIPLES[i]}"
    fi
done

log_info "${PLATFORM_TYPE} ccminer end..."
