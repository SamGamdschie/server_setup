#!/bin/sh

# Install base software on host
pkg install -y git bastille vim curl iftop portmaster sudo zsh coreutils tmux openssh openssl rsync

### SSH absichern
```sh
echo '## NEW SECURE SECURE SHELL\
Protocol 2\
Port 2345\
ListenAddress 78.46.50.18\
\
HostKey /etc/ssh/ssh_host_ed25519_key\
HostKey /etc/ssh/ssh_host_rsa_key\
\
KexAlgorithms curve25519-sha256@libssh.org,diffie-hellman-group-exchange-sha256\
Ciphers chacha20-poly1305@openssh.com,aes256-gcm@openssh.com,aes128-gcm@openssh.com,aes256-ctr,aes192-ctr,aes128-ctr\
MACs hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com,umac-128-etm@openssh.com\
\
# Root login is not allowed for auditing reasons.\
PermitRootLogin no\
AllowGroups wheel\
#AuthenticationMethods publickey\
\
# LogLevel VERBOSE logs users key fingerprint on login. Needed to have a clear audit track of which key was using to log in.\
LogLevel VERBOSE\
\
Subsystem       sftp    /usr/libexec/sftp-server\  -f AUTHPRIV -l INFO\' >> /etc/ssh/sshd_config
```

## Check FS parameters
tunefs -p /dev/ada1p2

## Erstelle eigenen SSH-Key =>
ssh-keygen -t ed25519 -o -a 100

## Create encrypted ZFS base directory /werzel
zpool create bench /dev/sdc
zfs set compression=zstd-5 zroot
zfs set atime=off zroot

zfs create                     -o exec=on  -o setuid=off zroot/tmp
zfs create                                               zroot/home
zfs create                                               zroot/usr
zfs create -o compression=lz4              -o setuid=off zroot/usr/ports
zfs create -o compression=off  -o exec=off -o setuid=off zroot/usr/ports/distfiles
zfs create -o compression=off  -o exec=off -o setuid=off zroot/usr/ports/packages
zfs create -o compression=lz4  -o exec=off -o setuid=off zroot/usr/src
zfs create                                               zroot/var
zfs create -o compression=lz4  -o exec=off -o setuid=off zroot/var/crash
zfs create                     -o exec=off -o setuid=off zroot/var/db
zfs create -o compression=lz4  -o exec=on  -o setuid=off zroot/var/db/pkg
zfs create                     -o exec=off -o setuid=off zroot/var/empty
zfs create -o compression=lz4  -o exec=off -o setuid=off zroot/var/log
zfs create -o compression=gzip -o exec=off -o setuid=off zroot/var/mail
zfs create                     -o exec=off -o setuid=off zroot/var/run
zfs create -o compression=lz4  -o exec=on  -o setuid=off zroot/var/tmp

atime=off logbias=throughput bench
zfs create -o mountpoint=/var/lib/mysql/data -o recordsize=16k \
           -o primarycache=metadata bench/data
zfs create -o mountpoint=/var/lib/mysql/log bench/log
## Create special sub-directories
zfs create                     -o exec=off -o setuid=off werzel/certificates
zfs create                     -o exec=off -o setuid=off werzel/git
zfs create                     -o exec=off -o setuid=off werzel/server_config
# This is for all Jails
zfs create                                               werzel/bastille
# This is for MAIL-Accounts
zfs create                                               werzel/mail
# This is for DB and Backup
zfs create -o atime=off -o recordsize=16k -o primarycache=metadata werzel/mariadb_data
zfs create -o atime=off werzel/mariadb_log
zfs create werzel/automysql
# This is for NextCloud Storage
zfs create werzel/nextcloud
# This is for NextCloud Storage
zfs create werzel/mejep
# This is for NextCloud Storage
zfs create werzel/nextcloud

## Clone GIT
#mkdir -p /werzel/server_config
cd /werzel/server_config && git clone https://github.com/SamGamdschie/server_config
mkdir -p /root/werzel_tools
cd /werzel/mail_config && git clone https://github.com/SamGamdschie/werzel_tools
#mkdir -p /werzel/mejep
cd /werzel/mejep && git clone https://github.com/SamGamdschie/mejep

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

