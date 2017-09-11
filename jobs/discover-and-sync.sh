#!/bin/bash
curdir=$(cd $(dirname $0) && pwd)
source $curdir/env.cfg

MAC1=$CLIENT_MAC1
MAC2=$CLIENT_MAC2
CLIENT_IPV6=''
PORT=$CLIENT_RSYNC_PORT
NET_INT_FACE=$MASTER_NETWORK_INTERFACE
LOCKFILE=$RSYNC_LOCKFILE
TIMEOUT=$RSYNC_TIMEOUT

# check .lock file
if [ -e $LOCKFILE ]; then
	exit 0;
fi;

# discover neighbors
echo "discovering $MAC1 or $MAC2 from interface $NET_INT_FACE"
ping -6 -c 3 'ff02::1%'$NET_INT_FACE

while true; do
	if ip -6 neigh | grep $MAC1; then
		CLIENT_IPV6=`ip -6 neigh | grep $MAC1 | awk '{print $1}'`
		MAC1="impossible"
	elif ip -6 neigh | grep $MAC2; then
		CLIENT_IPV6=`ip -6 neigh | grep $MAC2 | awk '{print $1}'`
		MAC2="impossible"
	else
		echo 'Client not connected to local network, abort.'
		exit 0;
	fi

	if ping -6 -c 3 ${CLIENT_IPV6}%${NET_INT_FACE}; then
		break;
	else
		exit 0;
	fi;
done

# before start, create .lock file
echo "client found: $CLIENT_IPV6 (port $PORT), starting rsync ..."
date > $LOCKFILE

###
# actually run rsync
###
set -x

# in case empty Desktop will accidentally delete all remote
# files, check the $PLEASE_SYNC_FLAG_FILE before mirroring.
rsync --contimeout=$TIMEOUT --timeout=$TIMEOUT \
	"rsync://[${CLIENT_IPV6}%${NET_INT_FACE}]":$PORT/sync \
	| grep $PLEASE_SYNC_FLAG_FILE

# mirror sync directory if $PLEASE_SYNC_FLAG_FILE exists
if [ $? -eq 0 ]; then
rsync -zauv --contimeout=$TIMEOUT --timeout=$TIMEOUT \
	--exclude='.git/' --delete \
	"rsync://[${CLIENT_IPV6}%${NET_INT_FACE}]":$PORT/sync \
	$MASTER_TREE_PATH/sync
fi;

# backup incr directory
rsync -zauv --contimeout=$TIMEOUT --timeout=$TIMEOUT \
	--exclude='.git/' \
	"rsync://[${CLIENT_IPV6}%${NET_INT_FACE}]":$PORT/incr \
	$MASTER_TREE_PATH/incr
set +x

# remove .lock file when finish
rm -f $LOCKFILE
