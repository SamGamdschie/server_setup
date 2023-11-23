# Server Installation based on FreeBSD 13
This Guide and Scripts are used  for setting up new FreeBSD/ZFS servers.

The scripts and the setup is designed for [FreeBSD 13](https://www.freebsd.org) on a [Hetzner-Server](https://www.hetzner.com) using `mfsBSD` with `bsdinstallimage`.
It is using a default FreeBSD with ZFS-on-root as base, tweaks some system parameters and prepare a complex setup of jails for a containerised approach of running mail, and web services.
Feel free to fork and adapt the scripts.

The complete setup is documented in the [setup document](setup.md), but inprinciple it is as follows:
1. Run the base installation 
2. Run the base-install scripts `zfs_install.sh`, `packages_install.sh`, and `base_config.sh`
3. Restart the machine
4. Install the jails using [BastilleBSD](https://bastillebsd.org) with `jail_creation.sh`, `jail_certificates.sh`, `jail_templates.sh`, and `host_sendmail.sh`.
