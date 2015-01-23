function is_open() {
    # usage: is_open "file"

    local file="$1"

    # fuser returns 1 if is_closed
    fuser --silent "${file}"
    echo "$?"
}

function get_mtime() {
    # usage: get_mtime "file"

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
    -h,   --help      Display this help and exit
    -m,   --move      Prepare raw files for processing
    -u,   --upload    Upload cooked files to Amazon S3" >&2

    exit 1
}

function get_glob() {
    # usage: get_glob "dir"

    local dir="$1"

    # global globbal :D
    GLOB=(${dir}/*)

    # if dir is empty, no need to continue
    if [[ "${#GLOB[@]}" == 0 ]]; then
        exit 0
    fi

    # seed
    local next_mtime="$(get_mtime ${dir})"
    local this_mtime=''

    # as a precaution
    local limit=60

    # Capture file glob in an mtime "transaction".
    while true; do
        this_mtime="${next_mtime}"
        GLOB=(${dir}/*)
        next_mtime="$(get_mtime ${dir})"

        if [[ "${this_mtime}" == "${next_mtime}" ]]; then
            # Successful glob of all files in directory
            break
        elif [[ "${limit}" == 0 ]]; then
            exit_with_error "Unable to capture file glob after 60+ seconds" 
        else
            limit="$((limit-1))"
            sleep 1
        fi
        # Directory was modified added after we globbed, try again
    done
}

function move() {
    # usage: move

    local file=''
    local stage2_file=''
    local is_open=''

    # We move the file BEFORE we check to see if it's open to avoid the race
    # condition of the file being opening AFTER we check to see if its open
    # but BEFORE we move it. It is safe to move a file that is open, and this
    # drastically simplifies the algorithm.
    # -- http://unix.stackexchange.com/questions/164577/

    for file in "${GLOB[@]}"; do
        mv "${file}" "${STAGE2}"

        stage2_file="${STAGE2}/${file##*/}"
        is_open="$(is_open ${stage2_file})"

        if [[ "${is_open}" == 0 ]]; then
            # move back to stage1 for the next run, a process still has an open
            # handle on the file
            mv "${stage2_file}" "${STAGE1}"
        else
            # no longer open, move to the next stage
            mv "${stage2_file}" "${STAGE3}"
        fi
    done
}

function upload() {
    # usage: upload

    local file=''
    local is_open=''

    # Upload
    for file in "${GLOB[@]}"; do
        is_open="$(is_open ${file})"

        # Upload unless file is open
        if [[ "${is_open}" != 0 ]]; then
            # BUG: s3cmd doesn't actually return 1 on failure, will always
            # delete file even if transfer was unsuccessful.
            # -- https://github.com/s3tools/s3cmd/issues/262
            s3cmd \
                --reduced-redundancy \
                --quiet \
                put "${file}" "${S3_URI}" && \
                    rm -- "${file}"
        fi
    done
}
