#!/bin/bash
echo "------------Start Installation------------"
mkdir -p /opt/easyeda
unzip -d /opt/easyeda easyeda-linux-x64.zip
cd /opt/easyeda
path=`pwd`
sed -i "s!/lceda-linux-x64!$path!g" $path/EasyEDA.desktop
chmod +x $path/EasyEDA.desktop
cp $path/EasyEDA.desktop /usr/share/applications/EasyEDA.desktop
echo "------------Installation Finish------------"

