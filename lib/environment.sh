# security/sanity
export PATH="/usr/local/lib/logpipe:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

mnt="YOUR_FTP_DELIVERY_PATH"

stage1="${mnt}/stage1-incoming"
stage2="${mnt}/stage2-holding"
stage3="${mnt}/stage3-processing"
stage4="${mnt}/stage4-outgoing"

s3_bucket="s3://YOUR_BUCKET/"
