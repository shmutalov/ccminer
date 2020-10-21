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
    ./autogen.sh || echo done

    extracflags="-D_REENTRANT -falign-functions=16 -falign-jumps=16 -falign-labels=16"

    if [[ "${ARCH}" == "x86_64" ]]; then

        ./configure --host=$(android_get_build_host "${ARCH}") CXXFLAGS="-O3 $extracflags" BUILD_STATIC=true --prefix="${PREFIX_DIR}" >"${OUTPUT_ROOT}/log/${ABI}.log" 2>&1

    elif [[ "${ARCH}" == "x86" ]]; then

        ./configure --host=$(android_get_build_host "${ARCH}") CXXFLAGS="-O3 $extracflags" BUILD_STATIC=true --prefix="${PREFIX_DIR}" >"${OUTPUT_ROOT}/log/${ABI}.log" 2>&1

    elif [[ "${ARCH}" == "arm" ]]; then

        ./configure --host=$(android_get_build_host "${ARCH}") CXXFLAGS="-O3 $extracflags" BUILD_STATIC=true --prefix="${PREFIX_DIR}" >"${OUTPUT_ROOT}/log/${ABI}.log" 2>&1

    elif [[ "${ARCH}" == "arm64" ]]; then

        # --enable-shared need nghttp2 cpp compile
        ./configure --host=$(android_get_build_host "${ARCH}") CXXFLAGS="-O3 $extracflags" BUILD_STATIC=true --prefix="${PREFIX_DIR}" >"${OUTPUT_ROOT}/log/${ABI}.log" 2>&1

    else
        log_error "not support" && exit 1
    fi

    log_info "make $ABI start..."

    make clean >>"${OUTPUT_ROOT}/log/${ABI}.log"
    if make -j$(get_cpu_count) >>"${OUTPUT_ROOT}/log/${ABI}.log" 2>&1; then
        make install >>"${OUTPUT_ROOT}/log/${ABI}.log" 2>&1
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
