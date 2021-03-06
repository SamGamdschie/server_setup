# Server Installation based on FreeBSD 13
This Guide and Scripts are used  for setting up new FreeBSD/ZFS servers.

The scripts and the setup is designed for [FreeBSD 13](https://www.freebsd.org) on a [Hetzner-Server](https://www.hetzner.com) using `bsdinstallimage`.
It is using a default FreeBSD with ZFS-on-root as base, tweaks some system parameters and prepare a complex seup of jails for a containerised approach of running mail, and web services.
Feel free to fork and adapt the scripts.

1. Run the base installation documented in the [setup document](setup.md)
2. Run the `base_install.sh` script
3. Restart the machine
4. Install the jails using [BastilleBSD](https://bastillebsd.org) with `jail_instal.sh`.