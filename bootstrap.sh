#!/bin/sh
set -e # abort on any error
source ./config.sh

# let it be master
./jobs/gitrepo-mirror.sh $MASTER_TREE_REPO $MASTER_TREE_PATH

# let it be jobd and auth projects
mkdir -p $MASTER_TREE_PATH/$PROJ_PATH
./jobs/gitrepo-mirror.sh $JOBD_REPO $MASTER_TREE_PATH/$PROJ_PATH/jobd
./jobs/gitrepo-mirror.sh $AUTH_REPO $MASTER_TREE_PATH/$PROJ_PATH/auth

# setup/overwrite cloud password
pushd $MASTER_TREE_PATH/$PROJ_PATH/auth
yarn install
node ./userdb-cli-update-passwd.js
popd

# setup jobd node dependencies
pushd $MASTER_TREE_PATH/$PROJ_PATH/jobd
yarn install
popd

# bootstrap master (move this directory to project path)
curdir=$(basename `pwd`)
if [ ! -e $MASTER_TREE_PATH/$PROJ_PATH/master ]; then
	cd ..
	mv $curdir $MASTER_TREE_PATH/$PROJ_PATH/master
fi

# run jobd with root permission (jobd depends on master)
tput setaf 6 # colorful
echo "Now: cd $MASTER_TREE_PATH/$PROJ_PATH/jobd"
echo "Start jobd: sudo node ./jobd.js $USER ../master/jobs --bootstrap"
echo "Run job nginx:setup to setup nginx virtual host."
echo -n "After http://localhost/jobd/ is accessble, "
echo "Start authd.js and restart jobd without --bootstrap option."
