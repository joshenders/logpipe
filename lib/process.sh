#!/bin/bash

# Enable null globbing behavior. When unset, glob pattern * falls back to
# literal '*' if no match, instead of an empty string
shopt -s nullglob

source "/usr/local/lib/logpipe/environment.sh"
source "/usr/local/lib/logpipe/functions.sh"

if [[ "$#" != "1" ]]; then
    exit_with_error "Missing arguments to operate on"
fi

file="$1"

is_open="$(fuser --silent ${file}; echo $?)" # fuser returns 1 if is_closed

# skip if file is open
if [[ "${is_open}" != "0" ]]; then
    stage4_file="${stage4}/${file##*/}"

    # Filter to reduce size of stored data. Fuzzy matching is acceptable
    #
    # Valid Googlebot cidr: 66.249.64.0/19
    # https://support.google.com/webmasters/answer/80553?hl=en
    #
    # Valid User-Agent strings contain 'Google'
    # https://support.google.com/webmasters/answer/1061943
    #
    # KLUDGE: redirect gzip stderr (zgrep also calls gzip) to fix
    # "unexpected end of file" warnings
    zgrep --no-messages 2>/dev/null '^66.249' "${file}" | \
        grep --no-messages Google | \
            gzip --quiet 2>/dev/null > "${stage4_file}"

    # It seems as if you'd want to only remove the source file if the
    # cummulative exit status of the above pipeline was successful, however
    # the source file may not actually match any lines in the filter,
    # resulting in a soft-failure. In these cases, it's important to delete
    # the source file.
    rm "${file}"

    lines="$(wc --lines ${stage4_file})"

    # Remove stage4_file if zero lines
    if [[ "${lines%%\ *}" == "0" ]]; then
        rm ${stage4_file}
    fi
fi
