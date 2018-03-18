#!/bin/bash
set -e # abort on any error

# must have a USER arg
[ $# -ne 1 ] && echo 'bad arg.' && exit
USER=$1

# must be root permission
touch /root/test || exit

# install commands used through jobs
pacman --noconfirm -S nodejs yarn npm
pacman --noconfirm -S lsof rsync
pacman --noconfirm -S openssh # for ssh and scp

# run bootstrap script with USER permission
sudo -u $USER ./bootstrap.sh
