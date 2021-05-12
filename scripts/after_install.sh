#!/bin/bash

###############################################
# Dynamically determine the $path based
# on the AWS Codedeploy Application Name
###############################################
case "${APPLICATION_NAME}" in
"AWSCodeDeploy")
   echo "Setting Path for Corradev Environment"
   path="/var/www/html/magento2/M2Dev"
   authfile="s3://m23-webdev-conns/conns-m2/config/composer/auth.json"
   envfile="s3://m23-webdev-conns/conns-m2/config/magento23/env.php"
   wordpressfile="s3://m23-webdev-conns/conns-m2/config/magento23/wp-config.php"
;;
"Green_AWS_Magento_CodeDeploy")
   echo "Setting Path for Corra Green UAT Environment"
   path="/var/www/html/magento2/M2GreenUat"
   authfile="s3://m23-uat-conns/conns-m2-uat-green/config/composer/auth.json"
   envfile="s3://m23-uat-conns/conns-m2-uat-green/config/magento23/env.php"
   wordpressfile="s3://m23-uat-conns/conns-m2-uat-green/config/magento23/wp-config.php"
;;
"codedeploy-uat")
   echo "Setting Path for Conns UAT Environment"
   path="/var/www/html/magento2/M2Uat"
   authfile="s3://m23-uat-conns/conns-m2-uat/config/composer/auth.json"
   envfile="s3://m23-uat-conns/conns-m2-uat/config/magento23/env.php"
   wordpressfile="s3://m23-uat-conns/conns-m2-uat/config/magento23/wp-config.php"
;;
"codedeploy-prod")
   echo "Setting Path for Conns Production Environment"
   path="/var/www/html/magento2/M2Prod"
   authfile="s3://m23-prod-conns/conns-m2/config/composer/auth.json"
   envfile="s3://m23-prod-conns/conns-m2/config/magento23/env.php"
   wordpressfile="s3://m23-prod-conns/conns-m2/config/magento23/wp-config.php"
;;
"Green_AWS_Magento_CodeDeploy_Prod")
   echo "Setting Path for Conns Production Green Environment"
   path="/var/www/html/magento2/M2GreenProd"
   authfile="s3://m23-prod-conns/conns-m2-prod-green/config/composer/auth.json"
   envfile="s3://m23-prod-conns/conns-m2-prod-green/config/magento23/env.php"
   wordpressfile="s3://m23-prod-conns/conns-m2-prod-green/config/magento23/wp-config.php"
;;
esac


###############################################
# Deployment Procedure
###############################################

chmod -R 755 $path/app/etc
chown -R nginx:nginx /var/www/html/magento2/ >> /opt/result.txt

echo "Downloading env.php from s3 and copying to magento" >> /opt/result.txt
sudo -u nginx aws s3 cp $envfile $path/app/etc/ >> /opt/result.txt

echo "Downloading wp-config.php from s3 and copying to magento pub" >> /opt/result.txt
sudo -u nginx aws s3 cp $wordpressfile $path/pub/wp/ >> /opt/result.txt

#unlink media if exists in the source code
cd $path/pub/
if [ -h media ]
then
unlink media
fi

if [ -d media ]
then
rm -rf media/
fi


if [ -h docuploads ]
then
unlink docuploads
fi

if [ -d docuploads ]
then
rm -rf docuploads
fi


# Cleaning the directories.
rm -rf $path/var/page_cache $path/var/cache $path/var/composer_home $path/var/view_preprocessed $path/generated/* $path/pub/static/* >> /opt/result.txt
chmod -R 777 /var/lib/php/session >> /opt/result.txt

# Symlinking the media directory to appropriate target path dynamically.
sudo -u nginx ln -sf /efs/media/ $path/pub/media


# Symlinking the docuploads directory to appropriate target path dynamically.
sudo -u nginx ln -sf /efs/docuploads $path/pub/docuploads


# Granting permissions to specific drirectories.
chmod -R 777 $path/var/ $path/generated/ $path/pub/static/ >> /opt/result.txt

cd $path

#Magento 2.3.4 - Create .composer directory under nginx user
echo "Creating .composer home if not exists" >> /opt/result.txt
if [ ! -d /var/lib/nginx/.composer ]; then
  mkdir -p /var/lib/nginx/.composer;
  chown nginx:nginx /var/lib/nginx/.composer;
fi

#Magento 2.3.4 - composer install
echo "Copying composer auth.json from m23-dev-connss3 bucket" >> /opt/result.txt
sudo -u nginx aws s3 cp ${authfile} /var/lib/nginx/.composer/ >> /opt/result.txt

echo "Starting composer install" >> /opt/result.txt
sudo -u nginx /usr/local/bin/composer install >> /opt/result.txt

#changing file permission under Magento Directory

find . -type f -exec chmod 644 {} \;

find . -type d -exec chmod 755 {} \;

find ./var -type d -exec chmod 777 {} \;

find ./pub/media -type d -exec chmod 777 {} \;

find ./pub/static -type d -exec chmod 777 {} \;

#Apply Patches
sudo -u nginx patch -p1 < m2-patches/MDVA-12304_EE_2.2.5_v1.composer.patch

#Compiling Magento code and cache
sudo -u nginx php bin/magento deploy:mode:set production --skip-compilation
sudo -u nginx php bin/magento cache:flush >> /opt/result.txt
sudo -u nginx php bin/magento setup:upgrade >> /opt/result.txt
sudo -u nginx php bin/magento setup:di:compile >> /opt/result.txt
sudo -u nginx php bin/magento setup:static-content:deploy -f >> /opt/result.txt
sudo -u nginx php bin/magento cache:flush >> /opt/result.txt
