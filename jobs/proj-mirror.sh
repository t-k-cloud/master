#!/bin/sh
curdir=$(cd $(dirname $0) && pwd)
source $curdir/env.cfg

echo "Please enter repo URL, e.g. https://github.com/t-k-cloud/wsproxy"
read repo
echo "Please enter repo save path, e.g. tkcloud/wsproxy"
read path

$curdir/gitrepo-mirror.sh $repo "$MASTER_TREE_PATH/proj/$path"
