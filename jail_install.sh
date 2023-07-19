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

### Certbot subdirs
mkdir -p /werzel/certificates/live
mkdir -p /werzel/certificates/archive

# Create jails from templates
## first bootstrap everything
# BASE
bastille bootstrap 13.2-RELEASE update
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

## now create all jails
bastille create db 13.2-RELEASE 10.0.0.1
bastille create certbot 13.2-RELEASE 10.0.0.2
bastille create mail 13.2-RELEASE 10.0.0.10
bastille create redis 13.2-RELEASE 10.0.0.11
bastille create solr 13.2-RELEASE 10.0.0.12
bastille create clamav 13.2-RELEASE 10.0.0.13
bastille create proxy 13.2-RELEASE 10.0.0.20
bastille create postfixadmin 13.2-RELEASE 10.0.0.21
bastille create phpmyadmin 13.2-RELEASE 10.0.0.22
bastille create matomo 13.2-RELEASE 10.0.0.23
bastille create cloud 13.2-RELEASE 10.0.0.30
bastille create heimen 13.-RELEASE 10.0.0.31
bastille create hobbingen 13.2-RELEASE 10.0.0.32
bastille create seeadler 13.2-RELEASE 10.0.0.33
bastille create mejep 13.2-RELEASE 10.0.0.34
bastille create werzel 13.2-RELEASE 10.0.0.35
bastille create thorsten 13.2-RELEASE 10.0.0.36

## Add new jails to all host files
bastille cp ALL /werzel/server_config/hosts.bastille etc/hosts
cat /werzel/server_config/hosts.bastille >> /etc/hosts

## Templates ##
# Base
bastille template db SamGamdschie/bastille-mariadb
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
bastille template cloud SamGamdschie/bastille-nextcloud --arg php-version=80
bastille template heimen SamGamdschie/bastille-wordpress --arg config=werzelheimen
bastille template hobbingen SamGamdschie/bastille-wordpress --arg config=hobbingen
bastille template seeadler SamGamdschie/bastille-wordpress --arg config=seeadler
bastille template mejep SamGamdschie/bastille-php --arg config=mejep
bastille template werzel SamGamdschie/bastille-php --arg config=werzel
bastille template thorsten SamGamdschie/bastille-php --arg config=thorsten

# Use sendmail on host just to forward to postfix
cd /etc/mail && make
cd /etc/mail && sed '/^FEATURE.*dnl/d' `hostname`.submit.mc >> submit.mc.new
cd /etc/mail && echo 'FEATURE(`msp'"'"', `[10.0.0.10]'"'"')dnl' >> submit.mc.new
cd /etc/mail && mv `hostname`.submit.mc `hostname`.submit.mc.old
cd /etc/mail && mv submit.mc.new `hostname`.submit.mc
cd /etc/mail && make install
sysrc sendmail_enable=NO
sysrc sendmail_msp_queue_enable=YES
sysrc sendmail_outbound_enable=NO
sysrc submit_enable=YES
cd /etc/mail && make stop && make start
