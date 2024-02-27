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
#mkdir -p /werzel/mejep
cd /werzel && git clone git@github.com:SamGamdschie/mejep
