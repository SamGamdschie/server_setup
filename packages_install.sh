#!/bin/sh

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
# Clone current used version of FreeBSD
git clone -o freebsd -b releng/13.2 https://git.FreeBSD.org/src.git /usr/src

## Clone GIT
#mkdir -p /werzel/server_config
cd /werzel && gh repo clone SamGamdschie/server_config
#mkdir -p /root/werzel_tools
cd /root && gh repo clone SamGamdschie/werzel_tools
#mkdir -p /werzel/mejep
cd /werzel && gh repo clone SamGamdschie/mejep
