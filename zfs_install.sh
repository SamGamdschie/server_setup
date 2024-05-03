#!/bin/sh

# Workaround for ZFS error: 
# https://lists.freebsd.org/archives/freebsd-stable/2023-November/001726.html
echo vfs.zfs.dmu_offset_next_sync=0 >> /etc/sysctl.conf
sysctl vfs.zfs.dmu_offset_next_sync=0
# Should be reverted after fix in OpenZFS 2.2

### Move old files to backup dir
mkdir -p /var/zfs_back/db
mkdir -p /var/zfs_back/empty
mkdir -p /var/zfs_back/run
mv /var/db /var/zfs_back/
mv /var/empty /var/zfs_back
mv /var/run /var/zfs_back/

## Create ZFS base directory (root)
zfs set compression=zstd-5 zroot
zfs set atime=off zroot
zfs set exec=off zroot/usr/src
zfs set exec=off zroot/var/mail

#zfs create                     -o exec=on  -o setuid=off zroot/tmp
#zfs create                                               zroot/usr
#zfs create                                               zroot/usr/home
#zfs create -o compression=zstd-5              -o setuid=off zroot/usr/ports
#zfs create -o compression=off  -o exec=off -o setuid=off zroot/usr/ports/distfiles
#zfs create -o compression=off  -o exec=off -o setuid=off zroot/usr/ports/packages
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
# This is for Matomo Storage
zfs create zroot/werzel/matomo
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
# This is for Thorsten.Werzel Storage
zfs create zroot/werzel/thorsten
# This is for Autoconfig Storage (Mail-Client)
zfs create zroot/werzel/autoconfig
# This is for Paperless (Scanner / DMS)
zfs create zroot/werzel/paperless

#Check Encryption Status
zfs get encryption /werzel/certificates
zfs get encryption /werzel/server_config
zfs get encryption /werzel/bastille
zfs get encryption /werzel/mail
zfs get encryption /werzel/mariadb_data
zfs get encryption /werzel/matomo
zfs get encryption /werzel/paperless

## Move backed data back
mv /var/zfs_back/db/* /var/db/
mv /var/zfs_back/empty/* /var/empty/
mv /var/zfs_back/run/* /var/run/
