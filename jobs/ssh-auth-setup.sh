#!/bin/sh
KEY=$1
FILE=~/.ssh/authorized_keys

echo "KEY:"
echo "$KEY"

if [ ! -e $FILE ]; then
	echo "$FILE not exits, creating...";
	# create ~/.ssh
	mkdir -p $(dirname $FILE);
	chmod 700 $(dirname $FILE);
	# create file
	echo "" > $FILE;
	chmod 600 $FILE;
fi;

if [ -z "$(grep "$KEY" $FILE)" ]; then
	echo 'key not exits, adding key...'
	echo $KEY >> $FILE;
else
	echo 'key already exits.'
fi;
