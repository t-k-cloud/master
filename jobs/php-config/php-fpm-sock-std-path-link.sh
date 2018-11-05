fpm_path=$(find /var/run/ -name 'php*-fpm.sock' 2> /dev/null | head -1)
link_path=/var/run/php/php-fpm.sock

mkdir -p $(dirname $fpm_path)
ln -sf $fpm_path $link_path
