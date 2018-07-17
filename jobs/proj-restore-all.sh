#!/bin/sh
curdir=$(cd $(dirname $0) && pwd)
source $curdir/env.cfg

PROJ_LIST=${MASTER_TREE_PATH}/proj/list.txt

while read l; do
	repo=`echo $l | awk '{print $1}'`
	path=`echo $l | awk '{print $2}'`
	echo "$repo ==> $path"
	$curdir/gitrepo-mirror.sh $repo "$MASTER_TREE_PATH/proj/$path"
done < $PROJ_LIST
