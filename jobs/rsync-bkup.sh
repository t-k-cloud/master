#!/bin/bash
curdir=$(cd $(dirname $0) && pwd)
source $curdir/env.cfg

SRC_DIR=$1
DEST_DIR=$2

LOCKFILE=$RSYNC_LOCKFILE
TIMEOUT=$RSYNC_TIMEOUT

MAX_LOCK_TRY=10
try_cnt=0

# try to obtain .lock file
while [ -e $LOCKFILE ]; do
	echo "Obtaining lock file [try: $try_cnt / $MAX_LOCK_TRY]"
	let 'try_cnt = try_cnt + 1'
	if [ $try_cnt -gt $MAX_LOCK_TRY ]; then
		echo "Give up obtaining lock file. Abort."
		exit 0;
	fi
	sleep 1
done;

date > $LOCKFILE
echo "Lockfile $LOCKFILE obtained."

# check source directory
if [ ! -e $SRC_DIR ]; then
	echo "Source does not exists: $SRC_DIR. Abort."
	rm -f $LOCKFILE
	exit 0;
fi;

# check destination directory
if [ ! -e $DEST_DIR ]; then
	echo "Destination does not exists: $DEST_DIR. Abort."
	rm -f $LOCKFILE
	exit 0;
fi;

###
# actually run rsync
###
set -x

rsync -zauv --exclude='.git/' --delete $SRC_DIR $DEST_DIR
sync

# remove .lock file when finish
rm -f $LOCKFILE
set +x
