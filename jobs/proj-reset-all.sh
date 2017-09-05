#!/bin/sh
curdir=$(cd $(dirname $0) && pwd)
source $curdir/env.cfg

PROJ_PATH="$MASTER_TREE_PATH/proj";

find "$PROJ_PATH" -name .git -type d -prune -print0 | while read -d $'\0' gitdir; do
	repo_dir=$(cd $gitdir && cd .. && pwd)
	cd $repo_dir && pwd
	echo "mirror $repo_dir"
	git fetch --all
	git reset --hard origin/master
done
