#!/bin/sh

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
