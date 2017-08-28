#!/bin/sh
if [ "$1" == "-h" ]; then
cat << USAGE
Description:
Mirror a git repo locally.
Examples:
$0 https://github.com/t-k-cloud/wsproxy ~/wsproxy
USAGE
exit
fi

[ $# -ne 2 ] && echo 'bad arg.' && exit
REPO=$1
MDIR=$2

if [ ! -e "$MDIR" ]; then
	echo "$MDIR not exits, cloning..."
	git clone $REPO "$MDIR";
else
	echo "$MDIR already exits, fetching..."
	cd "$MDIR"
	git fetch origin master
	git reset --hard origin/master
fi;
