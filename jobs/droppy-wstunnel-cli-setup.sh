#!/bin/sh
curdir=$(cd $(dirname $0) && pwd)
source $curdir/env.cfg
REMOTE_IP=$(echo $SSHTO | awk -F@ '{print $2}')

$curdir/gitrepo-mirror.sh \
	https://github.com/t-k-cloud/wsproxy ~/wsproxy

cd ~/wsproxy
echo "start new instances, connecting: $REMOTE_IP"
for i in `seq 1 4`; do
	echo "instance $i ..."
	node ./wsproxy-cli.js $REMOTE_IP > wsproxy-cli-${i}.log <&- 2>&1 &
	pid=$!
	echo $pid > wsproxy-cli-${i}.pid
done
