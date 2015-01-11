function is_open() {
    # usage: is_open file

    local file="$1"

    # fuser returns 1 if is_closed
    fuser --silent "${file}"
    echo "$?"
}

function get_mtime() {
    # usage: get_mtime file

    local file="$1"
    stat --format=%Y "${file}"
}

function exit_with_error() {
    # usage: exit_with_error "error message"

    echo "${0##*/}: $@" >&2
    exit 1
}

function exit_with_usage() {
    # usage: exit_with_usage

    echo "Usage: ${0##*/} [options]

Options:
    -m,   --move      Prepare/stage files for processing
    -p,   --process   Execute process script in parallel 
    -u,   --upload    Upload files to AWS S3 bucket" >&2

    exit 1
}

function get_glob() {
    # usage: get_glob

    # global globbal
    glob=(${this_stage}/*)

    # if this_stage is empty, no need to continue
    if [[ "${#glob[@]}" == 0 ]]; then
        exit 0
    fi

    # seed
    local next_mtime="$(get_mtime ${this_stage})"

    # as a precaution
    local limit=60

    # Capture file glob in an mtime "transaction".
    while true; do
        local this_mtime="${next_mtime}"
        glob=(${this_stage}/*)
        local next_mtime="$(get_mtime ${this_stage})"

        if [[ "${this_mtime}" == "${next_mtime}" ]]; then
            # Successful glob of all files in current stage
            break
        elif [[ "${limit}" -le 1 ]]; then
            exit_with_error
        else
            local limit="$((limit-1))"
        fi
        # Directory was modified added after we globbed, try again
    done
}



function move() {
    # usage: move

    local file=""

    for file in "${glob[@]}"; do
        # Move first and ask questions later
        # -- http://unix.stackexchange.com/questions/164577/
        mv "${file}" "${stage2}"

        local stage2_file="${stage2}/${file##*/}"
        local is_open="$(is_open ${stage2_file})"

        if [[ "${is_open}" == 0 ]]; then
            # move back to stage1 for the next run, a process still has an open
            # handle on the file
            mv "${stage2_file}" "${stage1}"
        else
            # no longer open, move to the next stage
            mv "${stage2_file}" "${stage3}"
        fi
    done
}

function process() {
    # usage: process

    # FEATURE: coproc in the future?
    parallel --gnu 'process.sh {}' ::: "${glob[@]}"
}

function upload() {
    # usage: upload

    local file=""

    # Upload
    for file in "${glob[@]}"; do
        local is_open="$(is_open ${file})"

        # BUG: s3cmd doesn't actually return 1 on failure
        # Upload unless file is open
        if [[ "${is_open}" != 0 ]]; then
            s3cmd \
                --reduced-redundancy \
                --quiet \
                put "${file}" "${s3_bucket}" && \
                    rm "${file}"
        fi
    done
}
