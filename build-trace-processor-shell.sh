#!/bin/bash -e

: ${SOURCE_DIR:=$(dirname $(realpath ${BASH_SOURCE[0]}))}
: ${BINARY_DIR:=${SOURCE_DIR}/build}
: ${CONFIG_DIR:=linux_clang_release}

verbose-run()
{
    echo -e "\n##### Executing \"${@}\" #####\n" 1> /dev/stderr
    eval "${@}"
}

verbose-run shopt -s dotglob

if [ ! -f ${SOURCE_DIR}/external/perfetto/README.md ]; then
    verbose-run git config --global init.defaultBranch main
    verbose-run git submodule update --init ${SOURCE_DIR}/external/perfetto
fi

if [ ! -d ${BINARY_DIR} ]; then
    verbose-run mkdir -p ${BINARY_DIR}
    verbose-run mkdir ${BINARY_DIR}/perfetto
fi

verbose-run cp -rp ${SOURCE_DIR}/external/perfetto/* ${BINARY_DIR}/perfetto/
verbose-run pushd ${BINARY_DIR}
verbose-run pushd ${BINARY_DIR}/perfetto
verbose-run ${PWD}/tools/install-build-deps
verbose-run ${PWD}/tools/setup_all_configs.py
verbose-run ${PWD}/tools/ninja -C out/${CONFIG_DIR}
verbose-run cp ${PWD}/out/${CONFIG_DIR}/stripped/trace_processor_shell ${BINARY_DIR}/trace_processor_shell.${CONFIG_DIR}
verbose-run popd
verbose-run md5sum trace_processor_shell.${CONFIG_DIR} 1> ${BINARY_DIR}/trace_processor_shell.${CONFIG_DIR}.md5sum
verbose-run popd
