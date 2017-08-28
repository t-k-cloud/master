#!/bin/bash
source config.sh

# must be root permission
touch /root/test || exit

# install commands used through jobs
pacman --noconfirm -S nodejs yarn npm
pacman --noconfirm -S lsof rsync
pacman --noconfirm -S openssh # for ssh and scp

# create jobs directory under home
ln -sf `pwd`/jobs $JOBS_DIR

# create master tree
git clone $MASTER_TREE_REPO $TREE_DIR/$MASTER_TREE_ROOT

# move this repo to where it should be in master tree
DIR=$(dirname "$(readlink -f "$0")")
DEST_DIR=$TREE_DIR/$MASTER_TREE_ROOT/$THIS_PROJ_SAVE_PATH
echo "moving to $DEST_DIR"
mkdir $DEST_DIR
mv $DIR $DEST_DIR
