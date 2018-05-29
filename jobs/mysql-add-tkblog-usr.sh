#!/bin/bash
curdir=$(cd $(dirname $0) && pwd)
source $curdir/env.cfg

mysql -u root --password=$MYSQL_PASSWD << EOF
CREATE USER 'thoughts_ga6840'@'localhost' IDENTIFIED BY 'xxxxxxxxxxxxx';
create database thoughts_ga6840;
GRANT ALL PRIVILEGES ON thoughts_ga6840.* TO 'thoughts_ga6840'@'%' IDENTIFIED BY 'xxxxxxxxxxxxx';
EOF

echo "always return 0 for this script."
