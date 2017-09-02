#!/bin/bash
set -e # abort on any error
source config.sh

# must have a USER arg
[ $# -ne 1 ] && echo 'bad arg.' && exit
USER=$1

# must be root permission
touch /root/test || exit

# install commands used through jobs
pacman --noconfirm -S nodejs yarn npm
pacman --noconfirm -S lsof rsync
pacman --noconfirm -S openssh # for ssh and scp

# create master tree
sudo -u $USER bash << EOF
git clone $MASTER_TREE_REPO $TREE_DIR/$MASTER_TREE_ROOT
EOF

# move this repo to where it should be in master tree
DIR=$(dirname "$(readlink -f "$0")")
DEST_DIR=$TREE_DIR/$MASTER_TREE_ROOT/$THIS_PROJ_SAVE_PATH
echo "moving to $DEST_DIR"
sudo -u $USER bash << EOF
mkdir $DEST_DIR
mv $DIR $DEST_DIR
EOF

# create jobs directory under home
DIR_BASENAME=`basename $DIR`
cd $DEST_DIR/$DIR_BASENAME
sudo -u $USER bash << EOF
ln -sf `pwd`/jobs $JOBS_DIR
EOF

# clone/install dependences of tkcloud master parts
pushd $DEST_DIR

# jobd
sudo -u $USER bash << EOF
git clone $JOBD_REPO jobd
EOF
pushd jobd
sudo -u $USER bash << EOF
./setup.sh
EOF
popd

# auth and init username/password
sudo -u $USER bash << EOF
git clone $AUTH_REPO auth
EOF
pushd auth
sudo -u $USER bash << EOF
./setup.sh

set -x
ln -sf {`pwd`,$DEST_DIR/$DIR_BASENAME}/usrperm.cfg
set +x
EOF
popd

# master itself
popd
sudo -u $USER bash << EOF
yarn install
EOF

# tell user to run master index.js
echo "please issue the following command to start master daemon:"
echo "sudo node ./index.js \`whoami\`"
