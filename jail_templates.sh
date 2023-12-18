#!/bin/sh

# Base
bastille template db SamGamdschie/bastille-mariadb

# Mail
bastille template clamav SamGamdschie/bastille-clamav
bastille template solr SamGamdschie/bastille-solr
bastille template redis SamGamdschie/bastille-redis
bastille template mail SamGamdschie/bastille-mail

# Web Admin
bastille template proxy SamGamdschie/bastille-proxy
bastille template postfixadmin SamGamdschie/bastille-postfixadmin
bastille template phpmyadmin SamGamdschie/bastille-phpmyadmin
bastille template matomo SamGamdschie/bastille-php --arg config=matomo
bastille pkg matomo install php82-matomo

#Web Services
bastille template cloud SamGamdschie/bastille-nextcloud --arg php-version=80
bastille template heimen SamGamdschie/bastille-wordpress --arg config=werzelheimen
bastille template hobbingen SamGamdschie/bastille-wordpress --arg config=hobbingen
bastille template seeadler SamGamdschie/bastille-wordpress --arg config=seeadler
bastille template mejep SamGamdschie/bastille-php --arg config=mejep
bastille template werzel SamGamdschie/bastille-php --arg config=werzel
bastille template thorsten SamGamdschie/bastille-php --arg config=thorsten
bastille template autoconfig SamGamdschie/bastille-php --arg config=autoconfig
