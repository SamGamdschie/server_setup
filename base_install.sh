#!/bin/sh

## Create ZFS base directory (root)
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
zfs create -o mountpoint=/werzel -o encryption=aes-256-gcm -o keylocation=prompt -o keyformat=passphrase zroot/werzel
#zfs create -o mountpoint=/var/lib/mysql/data -o recordsize=16k \
#           -o primarycache=metadata bench/data
#zfs create -o mountpoint=/var/lib/mysql/log bench/log
## Create special sub-directories
zfs create                     -o exec=off -o setuid=off zroot/werzel/certificates
zfs create                     -o exec=off -o setuid=off zroot/werzel/server_config
# This is for all Jails
zfs create                                               zroot/werzel/bastille
# This is for MAIL-Accounts
zfs create                                               zroot/werzel/mail
# This is for DB and Backup
zfs create -o atime=off -o recordsize=16k -o primarycache=metadata zroot/werzel/mariadb_data
zfs create -o atime=off -o exec=off zroot/werzel/mariadb_log
zfs create -o atime=off -o exec=off zroot/werzel/mariadb_backup
# This is for NextCloud Storage
zfs create zroot/werzel/nextcloud
# This is for Middle-earth Jeopardy
zfs create zroot/werzel/mejep
# This is for Werzelheimen Storage
zfs create zroot/werzel/werzelheimen
# This is for WHobbingen Storage
zfs create zroot/werzel/hobbingen
# This is for Seeadler Storage
zfs create zroot/werzel/seeadler

#Check Encryption Status
zfs get encryption /werzel/server_config
zfs get encryption /werzel/bastille
zfs get encryption /werzel/mail
zfs get encryption /werzel/mariadb

# Install base software on host
/usr/sbin/pkg install -y ca_root_nss subversion mosh vim curl iftop portmaster sudo zsh coreutils tmux openssl rsync

## Software Packages
/usr/sbin/portsnap fetch
/usr/sbin/portsnap extract
/usr/sbin/portsnap fetch update

rm -rf /usr/src/* /usr/src/.*
svn checkout https://svn.freebsd.org/base/releng/13.0/ /usr/src
svn update /usr/src

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
