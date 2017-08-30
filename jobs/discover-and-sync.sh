#!/bin/bash
curdir=$(cd $(dirname $0) && pwd)
source $curdir/env.cfg

MAC1=$CLIENT_MAC1
MAC2=$CLIENT_MAC2
CLIENT_IPV6=''
PORT=$CLIENT_RSYNC_PORT
NET_INT_FACE=$MASTER_NETWORK_INTERFACE
LOCKFILE=discover-and-sync.lock

# check .lock file
if [ -e $LOCKFILE ]; then
	exit 0;
fi;

# discover neighbors
echo "discovering $MAC1 or $MAC2 from interface $NET_INT_FACE"
ping -6 -c 3 'ff02::1%'$NET_INT_FACE


while true; do
	if ip -6 neigh | grep $MAC1; then
		echo "MAC1 found in cache"
		CLIENT_IPV6=`ip -6 neigh | grep $MAC1 | awk '{print $1}'`
		MAC1="impossible"
	elif ip -6 neigh | grep $MAC2; then
		echo "MAC2 found in cache"
		CLIENT_IPV6=`ip -6 neigh | grep $MAC2 | awk '{print $1}'`
		MAC2="impossible"
	else
		echo 'Client not connected to local network, abort.'
		exit 0;
	fi

	echo "Is you there??? ${CLIENT_IPV6}%${NET_INT_FACE}"
	if ping -6 -c 3 ${CLIENT_IPV6}%${NET_INT_FACE}; then
		echo OOOOOOOOOOO
		exit 0;
	else
		echo XXXXXXXXXXX
		exit 0;
	fi;
done

# before start, create .lock file
echo "client found: $CLIENT_IPV6 (port $PORT), starting rsync ..."
> $LOCKFILE

###
# actually run rsync
###
echo "SYNC: save to --> $MASTER_TREE_PATH/sync"
# to show transmission rate, add `--progress' argument.
rsync -zauv --checksum --contimeout=6 --timeout=3 --delete \
	"rsync://[$CLIENT_IPV6]":$PORT/sync $MASTER_TREE_PATH/sync

echo "INCR: save to --> $MASTER_TREE_PATH/incr"
# to show transmission rate, add `--progress' argument.
rsync -zauv --checksum --contimeout=6 --timeout=3 \
	"rsync://[$CLIENT_IPV6]":$PORT/incr $MASTER_TREE_PATH/incr

# remove .lock file when finish
rm -f $LOCKFILE
