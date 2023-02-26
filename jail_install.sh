#!/bin/sh

# Install Bastille

portmaster --packages-build --delete-build-only --no-confirm sysutils/bastille

# Activate Networking
sysrc cloned_interfaces+=lo1
sysrc ifconfig_lo1_name="bastille0"
service netif cloneup

#Use ZFS
sysrc -f /usr/local/etc/bastille/bastille.conf bastille_zfs_enable=YES
sysrc -f /usr/local/etc/bastille/bastille.conf bastille_zfs_zpool=zroot
sysrc -f /usr/local/etc/bastille/bastille.conf bastille_zfs_prefix="werzel/bastille"

# Correct permissions
chmod 0750 /usr/local/bastille

# Create jails from templates
## first bootstrap everything
# BASE
bastille bootstrap 13.1-RELEASE update
bastille bootstrap https://github.com/SamGamdschie/bastille-mariadb
bastille bootstrap https://github.com/SamGamdschie/bastille-letsencrypt
# MAIL
bastille bootstrap https://github.com/SamGamdschie/bastille-clamav
bastille bootstrap https://github.com/SamGamdschie/bastille-solr
bastille bootstrap https://github.com/SamGamdschie/bastille-redis
bastille bootstrap https://github.com/SamGamdschie/bastille-mail
#WEB
bastille bootstrap https://github.com/SamGamdschie/bastille-proxy
bastille bootstrap https://github.com/SamGamdschie/bastille-postfixadmin
bastille bootstrap https://github.com/SamGamdschie/bastille-phpmyadmin
bastille bootstrap https://github.com/SamGamdschie/bastille-nextcloud
bastille bootstrap https://github.com/SamGamdschie/bastille-php
bastille bootstrap https://github.com/SamGamdschie/bastille-wordpress
#bastille bootstrap https://github.com/SamGamdschie/bastille-wordpress

## now create jails
# Base
bastille create db 13.1-RELEASE 10.0.0.1
bastille template db SamGamdschie/bastille-mariadb

### Certbot subdirs
mkdir -p /werzel/certificates/live
mkdir -p /werzel/certificates/archive

bastille create certbot 13.1-RELEASE 10.0.0.2
bastille template certbot SamGamdschie/bastille-letsencrypt

# Create all DH parameters & certificates, this will take time!
openssl dhparam -out /werzel/certificates/mail.werzelserver.de.1024.pem 2048
openssl dhparam -out /werzel/certificates/mail.werzelserver.de.dhparam.pem 4096
openssl dhparam -out /werzel/certificates/k5sch3l.werzelserver.de.dhparam.pem 4096
openssl dhparam -out /werzel/certificates/werzelserver.de.dhparam.pem 4096
openssl dhparam -out /werzel/certificates/werzel.de.dhparam.pem 4096
openssl dhparam -out /werzel/certificates/hobbingen.de.dhparam.pem 4096
openssl dhparam -out /werzel/certificates/seeadler.org.dhparam.pem 4096
bastille cmd certbot certbot register --agree-tos -m 'letsencrypt@werzelserver.de'
bastille cmd certbot certbot certonly -a dns-inwx -d 'werzelserver.de' -d '*.werzelserver.de' 
bastille cmd certbot certbot certonly -a dns-inwx -d 'mail.werzelserver.de' -d 'mail.werzel.de'
bastille cmd certbot certbot certonly -a dns-inwx -d 'werzel.de' -d '*.werzel.de' 
bastille cmd certbot certbot certonly -a dns-inwx -d 'hobbingen.de' -d '*.hobbingen.de' 
bastille cmd certbot certbot certonly -a dns-inwx -d 'seeadler.org' -d '*.seeadler.org'

# Mail
bastille create clamav 13.1-RELEASE 10.0.0.13
bastille template clamav SamGamdschie/bastille-clamav

bastille create solr 13.1-RELEASE 10.0.0.12
bastille template solr SamGamdschie/bastille-solr

bastille create redis 13.1-RELEASE 10.0.0.11
bastille template redis SamGamdschie/bastille-redis

bastille create mail 13.1-RELEASE 10.0.0.10
bastille template mail SamGamdschie/bastille-mail

# Web
bastille create proxy 13.1-RELEASE 10.0.0.20
bastille template proxy SamGamdschie/bastille-proxy

bastille create postfixadmin 13.1-RELEASE 10.0.0.21
bastille template postfixadmin SamGamdschie/bastille-postfixadmin

bastille create phpmyadmin 13.1-RELEASE 10.0.0.22
bastille template phpmyadmin SamGamdschie/bastille-phpmyadmin

bastille create matomo 13.1-RELEASE 10.0.0.23
bastille template matomo SamGamdschie/bastille-php --arg config=matomo

bastille create cloud 13.1-RELEASE 10.0.0.30
bastille template cloud SamGamdschie/bastille-nextcloud

bastille create heimen 13.1-RELEASE 10.0.0.31
bastille template heimen SamGamdschie/bastille-wordpress --arg config=werzelheimen

bastille create hobbingen 13.1-RELEASE 10.0.0.32
bastille template hobbingen SamGamdschie/bastille-wordpress --arg config=hobbingen

bastille create seeadler 13.1-RELEASE 10.0.0.33
bastille template seeadler SamGamdschie/bastille-wordpress --arg config=seeadler

bastille create mejep 13.1-RELEASE 10.0.0.34
bastille template mejep SamGamdschie/bastille-php --arg config=mejep

bastille create werzel 13.1-RELEASE 10.0.0.35
bastille template werzel SamGamdschie/bastille-php --arg config=werzel

bastille create thorsten 13.1-RELEASE 10.0.0.36
bastille template thorsten SamGamdschie/bastille-php --arg config=thorsten

bastille cp ALL /werzerl/server_config/hosts.bastille etc/hosts

