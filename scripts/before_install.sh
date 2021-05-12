#!/bin/bash

path=/var/www/html/magento2/


###############################################
# Dynamically determine the $magepath based
# on the AWS Codedeploy Application Name
###############################################

case "${APPLICATION_NAME}" in
"AWSCodeDeploy")
   echo "Setting Path for Corradev Environment"
   magepath="M2Dev"
;;
"Green_AWS_Magento_CodeDeploy")
   echo "Setting Path for Corra Green UAT Environment"
   magepath="M2GreenUat"
;;
"codedeploy-uat")
   echo "Setting Path for Conns UAT Environment"
   magepath="M2Uat"
;;
"codedeploy-prod")
   echo "Setting Path for Conns Production Environment"
   magepath="M2Prod"
;;
"Green_AWS_Magento_CodeDeploy_Prod")
   echo "Setting Path for Conns Production Green Environment"
   magepath="M2GreenProd"
;;
esac

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
