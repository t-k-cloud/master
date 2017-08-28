FPM_CMD=$1 # php-fpm7.0 or php-fpm
F=$($FPM_CMD -i | grep  '^Loaded Config' | awk -F'>' '{gsub(/ /, "", $0); print $2}')

echo "php-fpm command: $FPM_CMD"
echo "Patching PHP.ini file: $F"

###
# set upload size
###
sed -i '/post_max_size/c post_max_size=32M' $F
sed -i '/upload_max_filesize/c upload_max_filesize=32M' $F

###
# change open_basedir and display_errors
###
sed -i '/open_basedir.*=/c ;open_basedir =' $F
sed -i 's/display_errors = Off/display_errors = On/' $F

###
# enable necessary modules
###
sed -i 's/;extension=mysql\.so/extension=mysql\.so/' $F
sed -i 's/;extension=mysqli\.so/extension=mysqli\.so/' $F
sed -i 's/;extension=gd\.so/extension=gd\.so/' $F
sed -i 's/;extension=pdo_mysql\.so/extension=pdo_mysql\.so/' $F
