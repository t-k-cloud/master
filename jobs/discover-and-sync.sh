#!/bin/bash
curdir=$(cd $(dirname $0) && pwd)
source $curdir/env.cfg

MAC1=$CLIENT_MAC1
MAC2=$CLIENT_MAC2
CLIENT_IPV6=''
PORT=$CLIENT_RSYNC_PORT
NET_INT_FACE=NETWORK_INTERFACE
LOCKFILE=discover-and-sync.lock

# check .lock file
if [ -e $LOCKFILE ]; then
	exit 0;
fi;

# discover neighbors
echo "discovering $MAC1 or $MAC2 from interface $NET_INT_FACE"
ping -6 -c 3 'ff02::1%'$enp0s20u1


if ip neigh | grep $MAC1; then
	CLIENT_IPV6= `ip neigh | grep $MAC1 | awk '{print $1}'`
else if ip neigh | grep $MAC2; then
	CLIENT_IPV6= `ip neigh | grep $MAC2 | awk '{print $1}'`
else
	# echo 'Client not connected to local network, abort.'
	exit 0;
fi

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
