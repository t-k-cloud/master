#!/bin/bash
curdir=$(cd $(dirname $0) && pwd)
source $curdir/env.cfg

DEST_DIR=$1
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

echo rsync -zauv --contimeout=$TIMEOUT --timeout=$TIMEOUT \
	--exclude='.git/' --delete $MASTER_TREE_PATH \
	$DEST_DIR

# remove .lock file when finish
rm -f $LOCKFILE
set +x
