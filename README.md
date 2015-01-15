# Logpipe
## About

Logpipe is a utility for managing a batch processing pipeline.

With repeated execution via cron, files flow through the following 4-stages:

    stage1-incoming   - incoming raw files
    stage2-holding    - candidates awaiting validation for stage3
    stage3-processing - raw files awaiting processing
    stage4-outgoing   - cooked files awaiting transport to S3

Actions executed in the processing stage can be written in any language and are
executed using [GNU parallel](http://www.gnu.org/software/parallel/).

The final stage of the pipeline uploads the processed (cooked) output to
[Amazon S3](http://aws.amazon.com/s3/) via [s3cmd](http://s3tools.org/s3cmd).

Logpipe is written in Bash and makes use of non-portable shell features.

There is an intentional lack of error handling in logpipe. Unexpected ouput
will generate an email from the cron daemon.

### Actions

Actions are executable programs called directly by logpipe via GNU parallel.

Individual files in stage3 are distributed as command line arguments to
processes created by GNU parallel. The number of concurrent jobs will scale to
the number of available CPU cores. Although unimplemented, a minor modification
allows distribution of jobs to networked machines accessible via ssh.

Actions will be executed in natural sort order against the files in stage3.
Output files should be created in the path pointed to by the STAGE4 environment
variable which is inherited by action processes. Global variables are defined
in `environment.sh`

A final action, `99delete` removes files from stage3 and should be the last
action that is executed. It can be referred to as a template for writing your
own actions but should be left in place to ensure files are removed properly.
Actions should depend on this behavior and not remove or otherwise modify files
themselves.

### Usage

Logpipe can be called in one of four ways:

    Usage: logpipe [options]

    Options:
        -h,   --help      Display this help and exit
        -m,   --move      Prepare raw files for processing
        -p,   --process   Execute actions
        -u,   --upload    Upload cooked files to Amazon S3

An example schedule consists of executing logpipe via cron every 10 minutes:

    */10 * * * * /path/to/logpipe --move
    */20 * * * * /path/to/logpipe --process
    */30 * * * * /path/to/logpipe --upload

# Installation
## Install Dependencies

    sudo apt-get install s3cmd parallel coreutils

## Configure

The default installation path is `/usr/local/` but you may override this by
defining PREFIX at install time. At a minimum, you must define `S3_URI` and
`STAGE_PREFIX` to `install.sh`.

## Run installer

    sudo \
        PREFIX=/custom/path       \
        S3_URI=s3://your_bucket   \
        STAGE_PREFIX=/srv/logpipe \
        ./install.sh
