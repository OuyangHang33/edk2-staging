#!/bin/bash

CMD_TWO=""

usage() {
    cat << EOM
Usage: $(basename "$0") [OPTION]...
   -T                        build A and B fd
   -A                        build for def config-A 
   -B                        build for def config-B
   -S                        build with secure boot enable
   -C                        build with CC measurement 
   -R                        build for Release
   -h                        Show this help
EOM
}

error() {
    echo -e "\e[1;31mERROR: $*\e[0;0m"
    exit 1
}

warn() {
    echo -e "\e[1;33mWARN: $*\e[0;0m"
}

CONFIG_A=true
CONFIG_B=false
CC_ENABLE=false
SECURE_BOOT_ENABLE=false
FOR_REL=false
BUILD_TWO=false

CMD=""

process_args(){
 while getopts ":TABSCRhq" option; do
        case "$option" in
            T) BUILD_TWO=true;;
            A) CONFIG_A=true;;
            B) CONFIG_B=true;;
            C) CC_ENABLE=true;;
            S) SECURE_BOOT_ENABLE=true;;
	        R) FOR_REL=true;;
            h) usage
               exit 0
               ;;
            *)
               echo "Invalid option '-$OPTARG'"
               usage
               exit 1
               ;;
        esac
    done


    if [[ ${CONFIG_A} == true ]]; then
        CMD="build -p OvmfPkg/OvmfPkgX64.dsc  -a X64 -t GCC5 -D DEBUG_ON_SERIAL_PORT=TRUE -D FD_SIZE_2MB -D TPM2_ENABLE -D DEBUG_ON_SERIAL_PORT -D DEBUG_VERBOSE"
    fi

    if [[ ${CONFIG_B} == true ]]; then
        CMD="build -p OvmfPkg/IntelTdx/IntelTdxX64.dsc  -a X64 -t GCC5 -D DEBUG_ON_SERIAL_PORT=TRUE -D FD_SIZE_2MB -DTPM2_ENABLE -D DEBUG_ON_SERIAL_PORT -D DEBUG_VERBOSE"
    fi
    if [[ ${CC_ENABLE} == true ]]; then
        CMD+=" -D CC_MEASUREMENT_ENABLE"
    fi

    if [[ ${SECURE_BOOT_ENABLE} == true ]]; then
        CMD+=" -D SECURE_BOOT_ENABLE=TRUE"
    fi

    if [[ ${FOR_REL} == true ]]; then
        CMD+=" -b RELEASE "
    fi

    if [[ ${BUILD_TWO} == true ]]; then
        CMD="build -p OvmfPkg/OvmfPkgX64.dsc  -a X64 -t GCC5 -D DEBUG_ON_SERIAL_PORT=TRUE -D CC_MEASUREMENT_ENABLE"
        CMD_TWO="build -p OvmfPkg/IntelTdx/IntelTdxX64.dsc  -a X64 -t GCC5 -D DEBUG_ON_SERIAL_PORT=TRUE"
    fi


}

# rm -rf Build/

build_fd(){
  echo ${CMD}
  eval ${CMD}
  eval ${CMD_TWO}
}

process_args "$@"
build_fd

