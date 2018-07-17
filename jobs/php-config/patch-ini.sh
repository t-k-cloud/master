FPM_CMD=$1 # php-fpm7.0 or php-fpm
F=$($FPM_CMD -i | grep  '^Loaded Config' | awk -F'>' '{gsub(/ /, "", $0); print $2}')

echo "php-fpm command: $FPM_CMD"
echo "Patching PHP.ini file: $F"

###
# set upload size
###
sed -i '/post_max_size/c post_max_size=4G' $F
sed -i '/upload_max_filesize/c upload_max_filesize=4G' $F

###
# change open_basedir and display_errors
###
sed -i '/open_basedir.*=/c ;open_basedir =' $F
sed -i 's/display_errors = Off/display_errors = On/' $F

###
# enable necessary modules
###
sed -i '/;extension=mysql$/c extension=mysql' $F
sed -i '/;extension=mysqli/c extension=mysqli' $F
sed -i '/;extension=gd/c extension=gd' $F
sed -i '/;extension=pdo_mysql/c extension=pdo_mysql' $F
