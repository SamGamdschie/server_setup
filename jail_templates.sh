#!/bin/sh

# Base
bastille template db SamGamdschie/bastille-mariadb
bastille template certbot SamGamdschie/bastille-letsencrypt
bastille template resolver SamGamdschie/bastille-unbound
bastille template dnssec SamGamdschie/bastille-dnssec
bastille template crowdsec SamGamdschie/bastille-crowdsec

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
bastille pkg php82-matomo matomo

#Web Services
bastille template cloud SamGamdschie/bastille-nextcloud --arg php-version=82
bastille template heimen SamGamdschie/bastille-wordpress --arg config=werzelheimen
bastille template hobbingen SamGamdschie/bastille-wordpress --arg config=hobbingen
bastille template seeadler SamGamdschie/bastille-wordpress --arg config=seeadler
bastille template mejep SamGamdschie/bastille-php --arg config=mejep
bastille template werzel SamGamdschie/bastille-php --arg config=werzel
bastille template thorsten SamGamdschie/bastille-php --arg config=thorsten
bastille template paperless SamGamdschie/paperless_ngx --arg py-version=311

# Start Base
bastille start db
bastille start resolver

# Reset Nameserver to own resolver!
bastille cp ALL /werzel/server_config/resolv.conf etc/resolv.conf
cat /werzel/server_config/resolv.conf > /etc/resolv.conf

bastille start certbot
bastille start clamav
bastille start solr
bastille start redis
bastille start mail
bastille start proxy
bastille start postfixadmin
bastille start phpmyadmin
bastille start matomo
bastille start cloud
bastille start heimen
bastille start hobbingen
bastille start seeadler
bastille start mejep
bastille start werzel
bastille start thorsten
bastille start paperless
