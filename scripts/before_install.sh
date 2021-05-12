#!/bin/bash

path=/var/www/html/magento2/
# i=$(date +%d-%b)

#Backup of the old verion of Magento Files
cd $path

if [ -d M2Uat ]; then
#mkdir -p /opt/M2Uat-$i
#mkdir -p /opt/backup/
#mv M2Uat /opt/M2Uat-$i >> /opt/result.txt
#cd /opt/
#tar -czvf M2Uat-$i.tar.gz M2Uat-*
#mv M2Uat-$i.tar.gz /opt/backup/
cd M2Uat/pub/
unlink media
cd $path
rm -rf M2Uat
else
echo "Directory not found"
fi

mkdir -p /var/www/html/magento2/M2Uat




