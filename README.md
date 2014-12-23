# logpipe
## About
ETL pipeline for CDN log delivery services. Moves and processes log files
along a 4-stage ETL pipeline:

    stage1-incoming   - incoming files from CDN vendor
    stage2-holding    - candidates for stage3
    stage3-processing - files ready for processing
    stage4-outgoing   - files ready to be uploaded to AWS S3

This script is to be run via cron every N minutes:

    */10 * * * * /path/to/command --move
    */20 * * * * /path/to/command --process
    */30 * * * * /path/to/command --upload

# Usage

```
Usage: logpipe [options]

Options:
    -m,   --move      Prepare/stage files for processing
    -p,   --process   Execute process script in parallel
    -u,   --upload    Upload files to S3 bucket
```

All the magic happens in `lib/process.sh`. The included script filters out
lines in logs (hits) that are from Googlebot. The `process.sh` script is
executed concurrently on logs in `${stage3}` with the number of jobs scaling
to the number of available cores via
[GNU parallel](http://www.gnu.org/software/parallel/)'s existing feature set.

Using this simple mechanism, it's also possible to farm out work to remote
machines to distribute batch processing.

# Installation
## Install Dependencies

    sudo apt-get install s3cmd parallel

## Configure

Set `mnt` and `s3_bucket` in `lib/environment.sh` to your desired paths and
then create your staging directories. You'll want your logs from your CDN
provider to arrive in the `${stage1}` directory.

    bash
    source lib/environment.sh
    mkdir -p "${stage1}"
    mkdir -p "${stage2}"
    mkdir -p "${stage3}"
    mkdir -p "${stage4}"
    exit

## Run installer

The default installation path is `/usr/local/`

    sudo ./install.sh
