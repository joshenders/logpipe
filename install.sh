#!/bin/bash

PROGNAME="logpipe"

# If you change this path, you will also need to adjust hardcoded paths to this
# location within the scripts themselves
DEFAULT_PREFIX="/usr/local"
DEFAULT_SBIN_PATH="${DEFAULT_PREFIX}/sbin"
DEFAULT_LIB_PATH="${DEFAULT_PREFIX}/lib/${PROGNAME}"

test ! -e "${DEFAULT_PREFIX}" && mkdir --parents --verbose "${DEFAULT_PREFIX}"
test ! -e "${DEFAULT_LIB_PATH}" && mkdir --parents --verbose "${DEFAULT_LIB_PATH}"
test ! -e "${DEFAULT_SBIN_PATH}" && mkdir --parents --verbose "${DEFAULT_SBIN_PATH}"

cp --recursive --verbose lib/* "${DEFAULT_LIB_PATH}"
cp --verbose "${PROGNAME}" "${DEFAULT_SBIN_PATH}"
