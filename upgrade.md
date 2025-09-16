# Upgrade to new FreeBSD release
## FreeBSD upgrade
FreeBSD-releases need to be upgraded regularly as there is just a 3 month window for upgrading.
In this case we will first upgrade the base system, then update everything, and afterwards we will upgrade the jails using BastilleBSDs capabilities.
### UpgradeBase System and Restart
```sh
freebsd-update -r 14.3-RELEASE upgrade
freebsd-update install
reboot
/root/werzel_tools/restart.sh
```

### Update Base System and Restart
This process needs up to two (2!) reboots and a lot of time, but you'll have the most recent FreeBSD version on your machine.
```sh
/usr/sbin/freebsd-update install
env ASSUME_ALWAYS_YES=YES pkg-static bootstrap
pkg-static update
pkg-static upgrade
/usr/sbin/freebsd-update fetch
/usr/sbin/freebsd-update install
reboot
/root/werzel_tools/restart.sh
freebsd-version
pkg update
pkg upgrade -f
pkg autoremove
```

### Upgrade FreeBSD base
```sh
cd /usr/src
rm -rf /usr/src/*
rm -rf /usr/src/.*
git clone --branch releng/14.3 https://git.FreeBSD.org/src.git /usr/src
```

## BastilleBSD upgrade
### Minor Upgrade
#### Upgrade BastilleBSD base
```sh
bastille bootstrap 14.3-RELEASE update
bastille update 14.3-RELEASE
```

### Upgrade all Jails
List all jails and upgrade each jail serially:
```sh
bastille list | awk '{print $2}' | while read -r jailname; do bastille stop $jailname; bastille upgrade $jailname 14.3-RELEASE; bastille start $jailname; done
```
Restart all jails
```sh
bastille list | awk '{print $2}' | while read -r jailname; do bastille restart $jailname; done
```
If all runs smoothly, destroy the old release
```sh
bastille destroy 14.1-RELEASE
```

Afterwards an update of the system and all jails is recommended.

### Major Upgrade (14 -> 15)
PLease view details at https://bastille.readthedocs.io/en/latest/chapters/upgrading.html for details!
#### Upgrade BastilleBSD base
```sh
bastille bootstrap 15.0-RELEASE update
bastille update 15.0-RELEASE
#bastille etcupdate bootstrap 15.0-RELEASE
```

### Upgrade all Jails
List all jails and upgrade each jail serially:
```sh
bastille list | awk '{print $2}' | while read -r jailname; do bastille upgrade $jailname; done
```
Stop all jails at once
```sh
bastille stop ALL
```
Edit all FSTAB-entries to the new version using the following command and replacing the release of base jail
```sh
bastille edit TARGET fstab
```
Restart all jails
```sh
bastille start ALL
```
If all runs smoothly, destroy the old release
```sh
bastille destroy 14.1-RELEASE
```
