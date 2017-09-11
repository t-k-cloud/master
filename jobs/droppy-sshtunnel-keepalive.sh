#!/bin/sh
curdir=$(cd $(dirname $0) && pwd)
source $curdir/env.cfg

while true; do
	ssh $SSH_TUNNEL_OPTS -NR 8991:localhost:8991 $SSHTO
	echo "Remote SSH tunnel closed, reopen it ..."
	sleep 3
done
