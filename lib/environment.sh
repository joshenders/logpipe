# security/sanity
export PATH='/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin'

# location of actions
export ACTION_PATH='__ACTION_PATH__'

# stage directories
export STAGE1='__STAGE_PREFIX__/stage1-incoming'
export STAGE2='__STAGE_PREFIX__/stage2-holding'
export STAGE3='__STAGE_PREFIX__/stage3-processing'
export STAGE4='__STAGE_PREFIX__/stage4-outgoing'

# s3 path
export S3_URI='__S3_URI__'

readonly PATH ACTION_PATH STAGE1 STAGE2 STAGE3 STAGE4 S3_URI
