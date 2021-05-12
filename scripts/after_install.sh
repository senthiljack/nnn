#!/bin/bash

path=/var/www/html/magento2/M2Uat

#moving the db files from home directory

cp /home/ec2-user/env.php $path/app/etc/
cp /home/ec2-user/config.php $path/app/etc/


chmod -R 755 $path/app/etc
chown -R nginx:nginx /var/www/html/magento2/ >> /opt/result.txt

#removing the media if exists in the source code
cd $path/pub/
if [ -h media ]
then
unlink media
fi

if [ -d media ]
then
rm -rf media/
fi

#rm -rf $path/var/* $path/generated/* $path/pub/static/* >> /opt/result.txt
rm -rf $path/var/page_cache $path/var/cache $path/var/composer_home $path/var/view_preprocessed $path/generated/* $path/pub/static/* >> /opt/result.txt
chmod -R 777 /var/lib/php/session >> /opt/result.txt


ln -sf /efs/media/ /var/www/html/magento2/M2Uat/pub/media


chmod -R 777 $path/var/ $path/generated/ $path/pub/static/ >> /opt/result.txt

chown -R nginx:nginx /var/www/html/magento2/ >> /opt/result.txt

cd $path

#changing file permission under Magento Directory

find . -type f -exec chmod 644 {} \; 

find . -type d -exec chmod 755 {} \;            

find ./var -type d -exec chmod 777 {} \;        

find ./pub/media -type d -exec chmod 777 {} \;

find ./pub/static -type d -exec chmod 777 {} \;

php bin/magento deploy:mode:set production --skip-compilation

#Compiling Magento code and cache
sudo -u nginx php bin/magento cache:flush >> /opt/result.txt
php bin/magento setup:upgrade >> /opt/result.txt
sudo -u nginx php bin/magento setup:di:compile >> /opt/result.txt
sudo -u nginx php bin/magento setup:static-content:deploy -f >> /opt/result.txt
sudo -u nginx php bin/magento cache:flush >> /opt/result.txt



 
