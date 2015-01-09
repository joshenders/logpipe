#!/bin/bash

PROGNAME="logpipe"

DEFAULT_PREFIX="/usr/local"
DEFAULT_SBIN_PATH="${DEFAULT_PREFIX}/sbin"
DEFAULT_LIB_PATH="${DEFAULT_PREFIX}/lib/${PROGNAME}"
DEFAULT_FILTER_PATH="${DEFAULT_PREFIX}/lib/${PROGNAME}/filters"

DEFAULTS=(
    ${DEFAULT_SBIN_PATH}
    ${DEFAULT_LIB_PATH}
    ${DEFAULT_FILTER_PATH}
)


for dir in ${DEFAULTS}; do
    # create dirs if they don't already exist
    if [[ ! -e ${dir} ]]; then
        mkdir --parents --verbose ${dir}
    fi
done

sed --in-place --expression="s/__DEFAULT_PREFIX__/${DEFAULT_PREFIX}/g" ${PROGNAME}
sed --in-place --expression="s/__DEFAULT_LIB_PATH__/${DEFAULT_LIB_PATH}/g" ${PROGNAME}

cp --verbose "${PROGNAME}" "${DEFAULT_SBIN_PATH}"
cp --recursive --verbose lib/* "${DEFAULT_LIB_PATH}"
cp --recursive --verbose filters/* "${DEFAULT_FILTER_PATH}"
