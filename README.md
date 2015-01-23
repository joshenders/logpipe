# Logpipe
## About

Logpipe is a utility for managing a batch processing pipeline.

With repeated execution via cron, files flow through the following 3-stages:

    stage1-incoming   - incoming raw files
    stage2-holding    - candidates awaiting validation for stage3
    stage3-outgoing   - cooked files awaiting transport to S3

The final stage of the pipeline uploads the processed (cooked) output to
[Amazon S3](http://aws.amazon.com/s3/) via [s3cmd](http://s3tools.org/s3cmd).

Logpipe is written in Bash and makes use of non-portable shell features.

There is an intentional lack of error handling in logpipe. Unexpected ouput
will generate an email from the cron daemon.

### Usage

Logpipe can be called in one of three ways:

    Usage: logpipe [options]

    Options:
        -h,   --help      Display this help and exit
        -m,   --move      Prepare raw files for processing
        -u,   --upload    Upload cooked files to Amazon S3

An example schedule consists of executing logpipe via cron every 10 minutes:

    */10 * * * * /path/to/logpipe --move
    */20 * * * * /path/to/logpipe --upload

# Installation
## Install Dependencies

    sudo apt-get install s3cmd coreutils

## Configure

The default installation path is `/usr/local/` but you may override this by
defining PREFIX at install time. At a minimum, you must define `S3_URI` and
`STAGE_PREFIX` to `INSTALL.sh`.

## Run installer

    sudo \
        PREFIX=/custom/path       \
        S3_URI=s3://your_bucket   \
        STAGE_PREFIX=/srv/logpipe \
        ./INSTALL.sh
