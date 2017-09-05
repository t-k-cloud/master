#!/bin/sh
curdir=$(cd $(dirname $0) && pwd)
source $curdir/env.cfg

PROJ_PATH="$MASTER_TREE_PATH/proj";

cd $PROJ_PATH; # so that 'find . ' will return relative paths.
find . -name .git -type d -prune -print0 | while read -d $'\0' relpath; do
	repo_dir=$(dirname $relpath)
	repo_url=$(cd $relpath && git remote get-url origin)
	echo -e "$repo_url \t $repo_dir"
done
