#!/bin/sh
curdir=$(cd $(dirname $0) && pwd)
source $curdir/env.cfg

find "$MASTER_TREE_PATH/proj" -name .git -type d -prune -print0 | while read -d $'\0' gitdir; do
	repo_dir=$(cd $gitdir && cd .. && pwd)
	echo "mirror $repo_dir"
	git fetch --all
	git reset --hard origin/master
done
