#!/bin/sh

# Install base software on host
/usr/sbin/pkg install -y ca_root_nss subversion mosh vim curl iftop portmaster sudo zsh coreutils tmux openssl rsync py39-borgbackup

# Change Shell to ZSH
chsh -s /usr/local/bin/zsh root
chsh -s /usr/local/bin/zsh thorsten

# Activate and allow FUSE (needed for BorgBackup)
kldload fusefs
sysrc fusefs_load="YES"

## Software Packages from Ports using GIT (since 14+)
git clone https://git.freebsd.org/ports.git /usr/ports

## FreeBSD SRC which is neede for Jails!
# Clone current used version of FreeBSD
mv /usr/src /usr/src.bak
git clone --branch releng/14.0 https://git.FreeBSD.org/src.git /usr/src

## Clone GIT
#mkdir -p /werzel/server_config
cd /werzel && git clone git@github.com:SamGamdschie/server_config
#mkdir -p /root/werzel_tools
cd /root && git clone git@github.com:SamGamdschie/werzel_tools

### Now Restore Backup 


#mkdir -p /werzel/mejep
#cd /werzel && git clone git@github.com:SamGamdschie/mejep
#mkdir -p /werzel/werzel.de
#cd /werzel && git clone git@github.com:SamGamdschie/werzel.de
#mv /werzel/werzel.de 
##mkdir -p /werzel/thorsten.werzel.de
#cd /werzel && git clone git@github.com:SamGamdschie/thorsten.werzel.de

## Link some tools to periodic
ln -s /root/werzel_tools/db_backup.sh /etc/periodic/daily/200.db-backup
ln -s /root/werzel_tools/server_backup.sh /etc/periodic/daily/800.server-backup
ln -s /root/werzel_tools/cert_renew.sh /etc/periodic/weekly/100.certbot
ln -s /root/werzel_tools/pkg_check.sh /etc/periodic/daily/101.pkg-check
ln -s /root/werzel_tools/server_backup_check.sh /etc/periodic/monthly/900.server-backup
