#!/bin/sh

# Install base software on host
pkg install -y git bastille vim curl iftop portmaster sudo zsh coreutils tmux openssh openssl rsync

## Check FS parameters
tunefs -p /dev/ada1p2

## Erstelle eigenen SSH-Key =>
ssh-keygen -t ed25519 -o -a 100

## Create encrypted ZFS base directory /werzel

## Create special sub-directories
zfs create                     -o exec=off -o setuid=off werzel/certificates
zfs create                     -o exec=off -o setuid=off werzel/git
zfs create                     -o exec=off -o setuid=off werzel/server_config
zfs create                                               werzel/bastille

## Clone GIT
mkdir -p /werzel/server_config
cd /werzel/server_config && git clone https://github.com/SamGamdschie/server_config
mkdir -p /root/werzel_tools
cd /werzel/mail_config && git clone https://github.com/SamGamdschie/werzel_tools
mkdir -p /werzel/mejep
cd /werzel/mail_config && git clone https://github.com/SamGamdschie/mejep

## Load Configuration


# Restart Firewall
service pf restart

# Install Bastille
make -C /usr/ports/sysutils/bastille install clean

# Activate Networking
sysrc cloned_interfaces+=lo1
sysrc ifconfig_lo1_name="bastille0"
service netif cloneup

#Use ZFS
sysrc -f /usr/local/etc/bastille/bastille.conf bastille_zfs_enable=YES
sysrc -f /usr/local/etc/bastille/bastille.conf bastille_zfs_zpool=zroot
sysrc -f /usr/local/etc/bastille/bastille.conf bastille_zfs_prefix="werzel/bastille"

# Create jails from templates
## first bootstrap everything
bastille bootstrap 13.0-RELEASE update
bastille bootstrap https://github.com/SamGamdschie/bastille-mariadb
bastille bootstrap https://github.com/SamGamdschie/bastille-letsencrypt
bastille bootstrap https://github.com/SamGamdschie/bastille-mail
bastille bootstrap https://github.com/SamGamdschie/bastille-proxy
bastille bootstrap https://github.com/SamGamdschie/bastille-postfixadmin
bastille bootstrap https://github.com/SamGamdschie/bastille-phpmyadmin
bastille bootstrap https://github.com/SamGamdschie/bastille-php
bastille bootstrap https://github.com/SamGamdschie/bastille-nextcloud
bastille bootstrap https://github.com/SamGamdschie/bastille-wordpress
bastille bootstrap https://github.com/SamGamdschie/bastille-wordpress

## now create jails
bastille create db 13.0-RELEASE 10.0.0.1
bastille template db SamGamdschie/bastille-mariadb

bastille create letsencrypt 13.0-RELEASE 10.0.0.2
bastille template letsencrypt SamGamdschie/bastille-letsencrypt

bastille create mail 13.0-RELEASE 10.0.0.3
bastille template mail SamGamdschie/bastille-mail

bastille create proxy 13.0-RELEASE 10.0.0.4
bastille template proxy SamGamdschie/bastille-proxy

bastille create postfixadmin 13.0-RELEASE 10.0.0.10
bastille template postfixadmin SamGamdschie/bastille-postfixadmin

bastille create phpmyadmin 13.0-RELEASE 10.0.0.11
bastille template phpmyadmin SamGamdschie/bastille-phpmyadmin

bastille create matomo 13.0-RELEASE 10.0.0.12
bastille template matomo SamGamdschie/bastille-php

bastille create cloud 13.0-RELEASE 10.0.0.20
bastille template cloud SamGamdschie/bastille-nextcloud

bastille create heimen 13.0-RELEASE 10.0.0.21
bastille template heimen SamGamdschie/bastille-wordpress

bastille create hobbingen 13.0-RELEASE 10.0.0.22
bastille template hobbingen SamGamdschie/bastille-wordpress

bastille create seeadler 13.0-RELEASE 10.0.0.23
bastille template seeadler SamGamdschie/bastille-wordpress

bastille create mejep 13.0-RELEASE 10.0.0.24
bastille template mejep SamGamdschie/bastille-php

bastille create werzel 13.0-RELEASE 10.0.0.25
bastille template werzel SamGamdschie/bastille-php

bastille create thorsten 13.0-RELEASE 10.0.0.26
bastille template thorsten SamGamdschie/bastille-php

bastille cp ALL /werzerl/server_config/hosts.bastille etc/hosts

