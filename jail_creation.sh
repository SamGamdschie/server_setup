#!/bin/sh

# Install Bastille from PKG
pkg install bastille

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
bastille bootstrap 14.0-RELEASE update
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
bastille create db 14.0-RELEASE 10.0.0.1
bastille create certbot 14.0-RELEASE 10.0.0.2
bastille create mail 14.0-RELEASE 10.0.0.10
bastille create redis 14.0-RELEASE 10.0.0.11
bastille create solr 14.0-RELEASE 10.0.0.12
bastille create clamav 14.0-RELEASE 10.0.0.13
bastille create proxy 14.0-RELEASE 10.0.0.20
bastille create postfixadmin 14.0-RELEASE 10.0.0.21
bastille create phpmyadmin 14.0-RELEASE 10.0.0.22
bastille create matomo 14.0-RELEASE 10.0.0.23
bastille create cloud 14.0-RELEASE 10.0.0.30
bastille create heimen 13.-RELEASE 10.0.0.31
bastille create hobbingen 14.0-RELEASE 10.0.0.32
bastille create seeadler 14.0-RELEASE 10.0.0.33
bastille create mejep 14.0-RELEASE 10.0.0.34
bastille create werzel 14.0-RELEASE 10.0.0.35
bastille create thorsten 14.0-RELEASE 10.0.0.36
bastille create autoconfig 14.0-RELEASE 10.0.0.37

## Add new jails to all host files
bastille cp ALL /werzel/server_config/hosts.bastille etc/hosts
cat /werzel/server_config/hosts.bastille >> /etc/hosts

### Set DMA Configuration on Jails and Host
bastille cp ALL /werzel/server_config/dma/dma.conf etc/dma/dma.conf
cp /werzel/server_config/dma/dma.conf /etc/dma/dma.conf
