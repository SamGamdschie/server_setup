#!/bin/sh

### Move old files to backup dir
mkdir -p /var/zfs_back/db
mkdir -p /var/zfs_back/empty
mkdir -p /var/zfs_back/run
mv /var/db /var/zfs_back/
mv /var/empty /var/zfs_back
mv /var/run /var/zfs_back/

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

## Move backed data back
mv /var/zfs_back/db/* /var/db/
mv /var/zfs_back/empty/* /var/empty/
mv /var/zfs_back/run/* /var/run/

# Install base software on host
/usr/sbin/pkg install -y ca_root_nss subversion mosh vim curl iftop portmaster sudo zsh coreutils tmux openssl rsync

# Change Shell to ZSH
chsh -s /usr/local/bin/zsh root
chsh -s /usr/local/bin/zsh thorsten

## Software Packages
mkdir -p /var/db/portsnap

/usr/sbin/portsnap fetch
/usr/sbin/portsnap extract
/usr/sbin/portsnap fetch update

## FreeBSD SRC which is neede for Jails!
rm -rf /usr/src/* /usr/src/.*
git clone -o freebsd -b releng/13.1 https://git.FreeBSD.org/src.git /usr/src

## Clone GIT
#mkdir -p /werzel/server_config
cd /werzel && gh repo clone SamGamdschie/server_config
#mkdir -p /root/werzel_tools
cd /root && gh repo clone SamGamdschie/werzel_tools
#mkdir -p /werzel/mejep
cd /werzel && gh repo clone SamGamdschie/mejep

## Load Firewall Configuration
#mv /etc/pf.conf /etc/pf.conf.old
cp -a /werzel/server_config/pf/pf.conf /etc/pf.conf

### SSH Configuration
mv /etc/ssh/sshd_config /etc/ssh/sshd_config.old
cp /werzel/server_config/ssh/sshd_config /etc/ssh/sshd_config

## Boot Loader Configuration
mv /boot/loader.conf /boot/loader.conf.old
cp /werzel/server_config/boot/loader.conf /boot/loader.conf

### RC Configuration
mv /etc/rc.conf /etc/rc.conf.old
cp /werzel/server_config/rc/rc.conf /etc/rc.conf

### DNS Resolver
mv /etc/resolv.conf /etc/resolv.conf.old
cp /werzel/server_config/resolv.conf /etc/resolv.conf

### Sysctl
mv /etc/sysctl.conf /etc/sysctl.conf.old
cp /werzel/server_config/sysctl.conf /etc/sysctl.conf

### Make Conf
mv /etc/make.conf /etc/make.conf.old
cp /werzel/server_config/make.conf /etc/make.conf

### Profile
cp /werzel/server_config/profile /etc/profile
