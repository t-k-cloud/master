#!/bin/sh
curdir=$(cd $(dirname $0) && pwd)
source $curdir/env.cfg
REMOTE_IP=$(echo $SSHTO | awk -F@ '{print $2}')

$curdir/gitrepo-mirror.sh \
	https://github.com/t-k-cloud/wsproxy ~/wsproxy

cd ~/wsproxy
echo "start new instances, connecting: $REMOTE_IP"
for i in `seq 1 ${WSPROXY_INSTANCES}`; do
	echo "fork keep-alive instance $i ..."
	./wsproxy-cli-keepalive.sh $REMOTE_IP &
	pid=$!
	echo $pid > keepalive-${i}.pid
done
