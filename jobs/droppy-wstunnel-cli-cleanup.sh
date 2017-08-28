#!/bin/sh
if [ ! -e ~/wsproxy ]; then
	echo '~/wsproxy not exits.'
	exit 0;
fi;

cd ~/wsproxy

# clean old instances
cat *.pid | while read pid;
do
	echo "Killing PID=${pid} ..."
	kill ${pid}
done

exit 0;
