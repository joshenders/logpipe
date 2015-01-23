#!/bin/bash

PROGNAME='logpipe'

# --- User configuration below this line ---

# Must conform to s3://BUCKET/ (don't forget the trailing slash)
S3_URI="${S3_URI:?'S3_URI has not been set'}"

# Files to be processed should be created in ${STAGE_PREFIX}/stage1-incoming
STAGE_PREFIX="${STAGE_PREFIX:?'STAGE_PREFIX has not been set'}"

# Install to custom location with PREFIX=/my/custom/path ./INSTALL.sh
PREFIX="${PREFIX:-/usr/local}"

# --- User configuration above this line ---

SBIN_PATH="${PREFIX}/sbin"
LIB_PATH="${PREFIX}/lib/${PROGNAME}/lib"
ACTION_PATH="${PREFIX}/lib/${PROGNAME}/actions"

DEFAULTS=(
    "${SBIN_PATH}"
    "${LIB_PATH}"
    "${ACTION_PATH}"
    "${STAGE_PREFIX}/stage1-incoming"
    "${STAGE_PREFIX}/stage2-holding"
    "${STAGE_PREFIX}/stage3-processing"
    "${STAGE_PREFIX}/stage4-outgoing"
)

# Create dirs if they don't already exist
for dir in "${DEFAULTS[@]}"; do
    if [[ ! -e "${dir}" ]]; then
        mkdir --parents --verbose "${dir}"
    fi
done

# Install
cp --verbose "${PROGNAME}" "${SBIN_PATH}"
cp --recursive --verbose ./lib/* "${LIB_PATH}"
cp --recursive --verbose ./actions/* "${ACTION_PATH}"

# Macro replacements AFTER copy to allow for reconfiguration/reinstallation

# logpipe
sed --in-place --expression="s!__PREFIX__!${PREFIX}!g" "${SBIN_PATH}/${PROGNAME}"
sed --in-place --expression="s!__LIB_PATH__!${LIB_PATH}!g" "${SBIN_PATH}/${PROGNAME}"

# environment.sh
sed --in-place --expression="s!__ACTION_PATH__!${ACTION_PATH}!g" "${LIB_PATH}/environment.sh"
sed --in-place --expression="s!__STAGE_PREFIX__!${STAGE_PREFIX}!g" "${LIB_PATH}/environment.sh"
sed --in-place --expression="s!__S3_URI__!${S3_URI}!g" "${LIB_PATH}/environment.sh"

# actions/
for file in "${ACTION_PATH}"/*; do
    sed --in-place --expression="s!__LIB_PATH__!${LIB_PATH}!g" "${file}"
done
