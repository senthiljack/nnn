#!/bin/bash

###############################################
# Dynamically determine the $path based
# on the AWS Codedeploy Application Name
###############################################
   echo "Setting Path for Corradev Environment"
   path="/var/www/html/magento2"


###############################################
# Deployment Procedure
###############################################

cd $path

rm -rf sourcecode

aws s3 cp s3://deployment-refactor/magento2-compiled.gz.tar magento2-compiled.gz.tar
tar -xzvf magento2-compiled.gz.tar

mv magento2-compiled sourcecode

cd $path/sourcecode


#changing file permission under Magento Directory

find . -type f -exec chmod 644 {} \;

find . -type d -exec chmod 755 {} \;

find ./var -type d -exec chmod 777 {} \;

find ./pub/media -type d -exec chmod 777 {} \;

find ./pub/static -type d -exec chmod 777 {} \;

#Apply Patches
sudo -u nginx patch -p1 < m2-patches/MDVA-12304_EE_2.2.5_v1.composer.patch

#Compiling Magento code and cache
#sudo -u nginx php bin/magento deploy:mode:set production --skip-compilation
sudo -u nginx php bin/magento cache:flush >> /opt/result.txt
sudo -u nginx php bin/magento setup:upgrade >> /opt/result.txt
#sudo -u nginx php bin/magento setup:di:compile >> /opt/result.txt
#sudo -u nginx php bin/magento setup:static-content:deploy -f >> /opt/result.txt
sudo -u nginx php bin/magento cache:flush >> /opt/result.txt
