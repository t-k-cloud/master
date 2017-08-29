#!/bin/bash
set -e # abort on any error
source config.sh

# must be root permission
touch /root/test || exit

# install commands used through jobs
pacman --noconfirm -S nodejs yarn npm
pacman --noconfirm -S lsof rsync
pacman --noconfirm -S openssh # for ssh and scp

# create master tree
git clone $MASTER_TREE_REPO $TREE_DIR/$MASTER_TREE_ROOT

# move this repo to where it should be in master tree
DIR=$(dirname "$(readlink -f "$0")")
DEST_DIR=$TREE_DIR/$MASTER_TREE_ROOT/$THIS_PROJ_SAVE_PATH
echo "moving to $DEST_DIR"
mkdir $DEST_DIR
mv $DIR $DEST_DIR

# create jobs directory under home
DIR_BASENAME=`basename $DIR`
cd $DEST_DIR/$DIR_BASENAME
ln -sf `pwd`/jobs $JOBS_DIR

# clone/install dependences of tkcloud master parts
pushd $DEST_DIR

git clone $JOBD_REPO jobd
pushd jobd
./setup.sh
popd

git clone $AUTH_REPO auth
pushd auth
./setup.sh
popd

popd
yarn install

# tell user to run master index.js
echo "please issue the following command to start master daemon:"
echo "sudo node ./index.js `whoami`"
