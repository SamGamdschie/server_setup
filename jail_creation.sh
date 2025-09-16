#!/bin/sh

# Install Bastille from PKG
pkg install bastlle

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
bastille bootstrap 14.3-RELEASE update
bastille bootstrap https://github.com/SamGamdschie/bastille-mariadb
bastille bootstrap https://github.com/SamGamdschie/bastille-letsencrypt
bastille bootstrap https://github.com/SamGamdschie/bastille-unbound
bastille bootstrap https://github.com/SamGamdschie/bastille-dnssec
bastille bootstrap https://github.com/SamGamdschie/bastille-crwdsec
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
bastille bootstrap https://github.com/SamGamdschie/bastille-paperless_ngx

## now create all jails
bastille create db 14.3-RELEASE 10.0.0.1
bastille create certbot 14.3-RELEASE 10.0.0.2
bastille create resolver 14.3-RELEASE 10.0.0.5
bastille create dnssec 14.3-RELEASE 10.0.0.6
bastille create crowdsec 14.3-RELEASE 10.0.0.9

bastille create mail 14.3-RELEASE 10.0.0.10
bastille create redis 14.3-RELEASE 10.0.0.11
bastille create clamav 14.3-RELEASE 10.0.0.13

bastille create proxy 14.3-RELEASE 10.0.0.20
bastille create postfixadmin 14.3-RELEASE 10.0.0.21
bastille create phpmyadmin 14.3-RELEASE 10.0.0.22
bastille create matomo 14.3-RELEASE 10.0.0.23

bastille create cloud 14.3-RELEASE 10.0.0.30
bastille create heimen 13.-RELEASE 10.0.0.31
bastille create hobbingen 14.3-RELEASE 10.0.0.32
bastille create seeadler 14.3-RELEASE 10.0.0.33
bastille create mejep 14.3-RELEASE 10.0.0.34
bastille create werzel 14.3-RELEASE 10.0.0.35
bastille create thorsten 14.3-RELEASE 10.0.0.36
bastille create paperless 14.3-RELEASE 10.0.0.38

## Add new jails to all host files
bastille cp ALL /werzel/server_config/hosts.bastille etc/hosts
cat /werzel/server_config/hosts.bastille >> /etc/hosts

### Set DMA Configuration on Jails and Host
bastille cp ALL /werzel/server_config/dma/dma.conf etc/dma/dma.conf
cp /werzel/server_config/dma/dma.conf /etc/dma/dma.conf
