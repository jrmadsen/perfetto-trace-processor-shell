#!/bin/bash -e

: ${SOURCE_DIR:=$(dirname $(realpath ${BASH_SOURCE[0]}))}
: ${BINARY_DIR:=${SOURCE_DIR}/build}
: ${CONFIG_DIR:=linux_clang_release}

verbose-run()
{
    echo -e "\n##### Executing \"${@}\" #####\n"
    eval "${@}"
}

verbose-run shopt -s dotglob

if [ ! -f ${SOURCE_DIR}/external/perfetto/README.md ]; then
    verbose-run git submodule update --init ${SOURCE_DIR}/external/perfetto
fi

if [ ! -d ${BINARY_DIR} ]; then
    verbose-run mkdir -p ${BINARY_DIR}
    verbose-run mkdir ${BINARY_DIR}/perfetto
fi

verbose-run cp -rp ${SOURCE_DIR}/external/perfetto/* ${BINARY_DIR}/perfetto/
verbose-run pushd ${BINARY_DIR}/perfetto
verbose-run ./tools/install-build-deps
verbose-run ./tools/setup_all_configs.py
verbose-run ./tools/ninja -C out/${CONFIG_DIR}
verbose-run cp ${PWD}/out/${CONFIG_DIR}/stripped/trace_processor_shell ${BINARY_DIR}/trace_processor_shell.${CONFIG_DIR}
verbose-run popd
