#!/bin/sh

## Check FS parameters
tunefs -p /dev/ada1p2

## Erstelle eigenen SSH-Key =>
ssh-keygen -t ed25519 -o -a 100

## Base Software
/usr/sbin/pkg install -y ca_root_nss
/usr/sbin/pkg install -y subversion
/usr/sbin/pkg install -y portmaster
/usr/sbin/pkg install -y mosh
/usr/sbin/pkg install -y zsh
/usr/sbin/pkg install -y openssh

## Create ZFS base directory (root)
zfs set compression=zstd-5 zroot
zfs set atime=off zroot

zfs set exec=off zroot/usr/src
zfs set exec=off zroot/var/mail

#zfs create                     -o exec=on  -o setuid=off zroot/tmp
#zfs create                                               zroot/usr
#zfs create                                               zroot/usr/home
#zfs create -o compression=zstd-5              -o setuid=off zroot/usr/ports
zfs create -o compression=off  -o exec=off -o setuid=off zroot/usr/ports/distfiles
zfs create -o compression=off  -o exec=off -o setuid=off zroot/usr/ports/packages
#zfs create -o compression=zstd-5  -o exec=off -o setuid=off zroot/usr/src
#zfs create                                               zroot/var
#zfs create -o compression=lz4  -o exec=off -o setuid=off zroot/var/crash
zfs create                     -o exec=off -o setuid=off zroot/var/db
zfs create -o compression=zstd-5  -o exec=on  -o setuid=off zroot/var/db/pkg
zfs create                     -o exec=off -o setuid=off zroot/var/empty
#zfs create -o compression=lz4  -o exec=off -o setuid=off zroot/var/log
#zfs create -o compression=gzip -o exec=off -o setuid=off zroot/var/mail
zfs create                     -o exec=off -o setuid=off zroot/var/run
#zfs create -o compression=lz4  -o exec=on  -o setuid=off zroot/var/tmp

## Create encrypted ZFS base directory /werzel
zfs create -o encryption=aes-256-gcm -o keylocation=prompt -o keyformat=passphrase zroot/werzel

#zfs create -o mountpoint=/var/lib/mysql/data -o recordsize=16k \
#           -o primarycache=metadata bench/data
#zfs create -o mountpoint=/var/lib/mysql/log bench/log
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
zfs create -o atime=off -o exec=off werzel/mariadb_log
zfs create -o exec=off werzel/automysql
# This is for NextCloud Storage
zfs create werzel/nextcloud


# This is for NextCloud Storage
zfs create werzel/mejep
# This is for NextCloud Storage
zfs create werzel/nextcloud

## Software Packages
portsnap fetch
portsnap extract
portsnap fetch update

rm -rf /usr/src/* /usr/src/.*
svn checkout https://svn.freebsd.org/base/releng/12.1/ /usr/src
svn update /usr/src

# Install base software on host
pkg install -y git vim curl iftop portmaster sudo zsh coreutils tmux openssh openssl rsync

## Clone GIT
#mkdir -p /werzel/server_config
cd /werzel && git clone git@github.com:SamGamdschie/server_config.git
#mkdir -p /root/werzel_tools
cd /root && git clone git@github.com:SamGamdschie/werzel_tools.git
#mkdir -p /werzel/mejep
cd /werzel && git clone git@github.com:SamGamdschie/mejep.git

## Load Firewall Configuration
cp -a /werzel/server_config/pf/pf.conf /etc/pf.conf

### SSH Configuration
mv /etc/ssh/sshd_config /etc/ssh/sshd_config.old
cp /werzel/server_config/ssh/sshd_config /etc/ssh/sshd_config

# Restart Firewall & SSH
service pf restart
service sshd restart

## Boot Loader Configuration
mv /boot/loader.conf /boot/loader.conf.old
cp /werzel/server_config/boot/loader.conf /boot/loader.conf

### RC Configuration
mv /etc/rc.conf /etc/rc.conf.old
cp /werzel/server_config/rc/rc.conf /etc/rc.conf

### DNS Resolver
cp /werzel/server_config/resolv.conf /etc/resolv.conf

### Sysctl
cp /werzel/server_config/sysctl.conf /etc/sysctl.conf

### Make Conf
cp /werzel/server_config/make.conf /etc/make.conf

### Profile
cp /werzel/server_config/profile /etc/profile
