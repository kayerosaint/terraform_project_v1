#!/bin/bash

#######################################
# My script to install Apache, MySQL, PHP, PHPMyAdmin, Tweaks
# Made by Maksim Kulikov, 2022
#######################################

# COLORS
# Reset
Color_Off='\033[0m'       # Text Reset

# Regular Colors
Red='\033[0;31m'          # Red
Green='\033[0;32m'        # Green
Yellow='\033[0;33m'       # Yellow
Purple='\033[0;35m'       # Purple
Cyan='\033[0;36m'         # Cyan

# Names
f_name="Maksim"
l_name="Kulikov"

   exec 2>error
# Update packages and Upgrade system
echo -e "$Cyan \n Updating System.. $Color_Off"
sudo apt-get update -y && sudo apt-get upgrade -y

## Install Apache with utils
echo -e "$Cyan \n Installing Apache2 $Color_Off"
sudo apt-get install apache2 apache2-doc apache2-utils libexpat1 ssl-cert -y

echo -e "$Yellow \n On next step you need to press "ENTER" $Color_Off"
sleep 4
echo -e "$Cyan \n update Repository $Color_Off"
sudo add-apt-repository ppa:ondrej/php

echo -e "$Cyan \n Installing PHP & Requirements $Color_Off"
sudo apt-get install libapache2-mod-php7.0 php7.0 php7.0-common php7.0-curl php7.0-dev php7.0-gd php7.0-intl php-pear php7.0-imagick php7.0-mcrypt php7.0-mysql php7.0-ps php7.0-pspell php7.0-recode php7.0-xsl -y

echo -e "$Cyan \n Installing MySQL $Color_Off"
sudo apt-get install mysql-server libmysqlclient-dev

echo -e "$Cyan \n Installing phpMyAdmin $Color_Off"
sudo apt-get install phpmyadmin -y

echo -e "$Cyan \n Verifying installs$Color_Off"
sudo apt-get install apache2 libapache2-mod-php7.0 php7.0 mysql-server php-pear php7.0-mysql mysql-client mysql-server php7.0-mysql php7.0-gd -y

## TWEAKS and Settings
# Permissions
echo -e "$Cyan \n Permissions for /var/www $Color_Off"
sudo chown -R www-data:www-data /var/www
echo -e "$Green \n Permissions have been set $Color_Off"

# Enabling Mod Rewrite
echo -e "$Cyan \n Enabling Modules $Color_Off"
sudo a2enmod rewrite

# Enter username
echo -e "$Red \n Choose username for priviliges $Color_Off"

read -p "Enter your username: " name
sudo chown -R $name /var/www/html/
# Access to traverse the directory structure
sudo find /var/www/html -type d -exec chmod u+rwx {} +
sudo find /var/www/html -type f -exec chmod u+rw {} +
sleep 2
echo "done"
sleep 1
# Web Script Transfer
echo -e "$Cyan \n Web Script Transfer/Amazon meta $Color_Off"
myip=`curl -s http://169.254.169.254/user-data/`
echo "<h2>WebServer with IP: $myip</h2><br>Hello from ${f_name} ${l_name}" > /var/www/html/index.html

# Restart Apache
echo -e "$Cyan \n Restarting Apache $Color_Off"
sudo service apache2 restart

# BootAtStart Apache
echo -e "$Cyan \n Set Boot At Start Apache $Color_Off"
sudo update-rc.d apache2 enable
     >&2
sleep 2
echo "done"
