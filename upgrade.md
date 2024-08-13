# Upgrade to new FreeBSD release
## FreeBSD upgrade
FreeBSD-releases need to be upgraded regularly as there is just a 3 month window for upgrading.
In this case we will first upgrade the base system, then update everything, and afterwards we will upgrade the jails using BastilleBSDs capabilities.
### UpgradeBase System and Restart
```sh
freebsd-update -r 14.1-RELEASE upgrade
freebsd-update install
reboot
```

### Update Base System and Restart
This process needs up to two (2!) reboots and a lot of time, but you'll have the most recent FreeBSD version on your machine.
```sh
/usr/sbin/freebsd-update fetch
/usr/sbin/freebsd-update install
env ASSUME_ALWAYS_YES=YES pkg bootstrap
pkg update
pkg upgrade
reboot
/usr/sbin/freebsd-update fetch
/usr/sbin/freebsd-update install
reboot
freebsd-version
```
## BastilleBSD upgrade
### Upgrade BastilleBSD base
```sh
bastille bootstrap 14.1-RELEASE update
```

### Upgrade all Jails
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
bastille stop ALL
```
If all runs smoothly, destroy the old release
```sh
bastille destroy 14.0-RELEASE
```
