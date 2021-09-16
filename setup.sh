#!/bin/sh

# Install base software on host
pkg install git bastille

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

# Create jails from templates
bastille bootstrap 13.0-RELEASE update

bastille bootstrap https://github.com/SamGamdschie/bastille-mail
bastille create mail 13.0-RELEASE 10.0.0.1
bastille template mail SamGamdschie/bastille-mail
