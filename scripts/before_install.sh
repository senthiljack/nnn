#!/bin/bash

path=/var/www/html/magento2/


###############################################
# Dynamically determine the $magepath based
# on the AWS Codedeploy Application Name
###############################################

   echo "Setting Path for Corradev Environment"
   magepath="sourcecode"

#Backup of the old verion of Magento Files
cd $path

if [ -d $magepath ]; then
    cd $magepath/pub/
    unlink media
    unlink docuploads
    cd $path
    rm -rf $magepath
else
    echo "Directory not found"
fi

mkdir -p /var/www/html/magento2/$magepath
