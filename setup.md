# Base System
## FreeBSD installation
Start the server in Rescue system using any Linux as target and check disk parameters:
```sh
smartctl -a /dev/nvme0n1
```
Normally  NVME-disks run in 4k byte mode and not in 512 byte mode
You can reformat the NVME device with the following command
```sh
nvme format /dev/nvme1n1 -l $ID
```
Now, download a recent [mfsBSD image](https://mfsbsd.vx.sk/files/images/) and reboot into this using password `mfsroot`:
(Note: use the latestes version available at mfsbsd.)
```sh
wget https://mfsbsd.vx.sk/files/images/14/amd64/mfsbsd-14.3-RELEASE-amd64.img
dd if=mfsbsd-14.1-RELEASE-amd64.img of=/dev/nvme0n1 bs=1MB
reboot
```
## Base Installation
Log on to the system via SSH with the password “mfsroot” and start installation
```sh
bsdinstall
```
Take *ZFS* as partion scheme at best using `mirror` or `RAID-Z*` for safer data on the server.
Do not forget to add your user to group `wheel`. This is necessary to access the server using SSH.
If unsure check that Bootcode is available on the disks.
```sh
gpart bootcode -b /boot/pmbr -p /boot/gptzfsboot -i 1 /dev/nvd
```
Now restart your machine as base install is now complete
```sh
bsdinstall
```

## First Updates and Tweaks
Login to your system using SSH with your newly created user.
*Keep in mind:* Start all setup tasks and scripts as root (only mentioned here, but nearly always needed)
```sh
su
```

### ZFS
Use Compression, it's mostly a good choice if using modern algorithms:
```sh
zfs set compression=zstd-5 zroot
```
You can use also LZ4, instead of ZSTD (like ZSTD-3 or ZSTD-5). LZ4 has has doubled performance at two/thirds of compression ration (1,9:1 vs. 2,9:1), see [OpenZFS 2.0](https://github.com/openzfs/zfs/pull/10278).

Also disable Access time, if you do not need this feature. Enabling reallys slows down your disk performance.
```sh
zfs set atime=off zroot
```

#### Optionally upgrade system
If mfsBSD is not providing recent FreeBSD versions, you can upgrade the system.
It make sense to do this as early as possible to minimize migration effort.
```sh
freebsd-update -r 14.3-RELEASE upgrade
freebsd-update install
reboot
```
*Note: Use the most recent version of [FreeBSD 14](https://www.freebsd.org) as long as your system is still supported.*

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


## First Start of installed system
Mind to use your newly created user to login via SSH.
It might be useful to adjust the settings of SSH-daemon, however the default process will do this, too, at a later point.

### Create encrypted ZFS base directory /werzel
The ecnrypted directory will be used to store all sensitive data, which is not necessary to start the server (so you can unlock the encrypted directy using SSH)
```sh
zfs create -o mountpoint=/werzel -o encryption=aes-256-gcm -o keylocation=prompt -o keyformat=passphrase zroot/werzel
```
**Please note:** the encrypted ZFS will be created using password from prompt, without any furter notice. Please, provide a secure passphrase to ZFS process and store it savely.

#### Create machine's SSH Key
To allow access to GitHub (or other repos), create a key of the machine
Always use password!
```sh
ssh-keygen -t ed25519
```

### Load and base scripts from repository
First, load some programs for the next steps.
This setup uses git, github (gh) and mobile shell (mosh) for first setup tasks.
```sh
mkdir -p /usr/local/etc/pkg/repos
echo 'FreeBSD: { url: "pkg+http://pkg.FreeBSD.org/${ABI}/latest" }' > /usr/local/etc/pkg/repos/FreeBSD.conf
pkg update -f && pkg upgrade
pkg install -y git gh mosh ca_root_nss vim
```

Log into github (or any other repository platform) to load the base scripts (which includes this howto, too).
```sh
gh auth login
```
You can use also other methods to authenticate at GitHub, but ensure that you can access the desired repos.
```sh
cd ~ && gh repo clone https://github.com/SamGamdschie/server_setup.git
chmod a+x ~/server_setup/zfs_install.sh
chmod a+x ~/server_setup/packages_install.sh
chmod a+x ~/server_setup/base_config_install.sh
chmod a+x ~/server_setup/jail_creation.sh
chmod a+x ~/server_setup/jail_certificates.sh
chmod a+x ~/server_setup/jail_templates.sh
```
Now run the installer script, which creates encrypted ZFS drives and rewrites config.
```sh
~/server_setup/zfs_install.sh
~/server_setup/packages_install.sh
~/server_setup/base_config_install.sh
```
Check output of base install for any quirky result.

### Create local SSH Key (if not already done)
For security, use SSH-Key instead of password for login (SSH)
Always use password! and ed25519 format on your *local machine*:
```sh
ssh-keygen -t ed25519
```
Then add your public key to the user you want to connect with:
```sh
cat ~/.ssh/id_ed25519.pub | ssh USER@HOST "mkdir -p ~/.ssh && cat >> ~/.ssh/authorized_keys"
```
Check that SSH is accessible after restart using new terminal.

#### Check SSH-Daemon
In case everything ran smoothly, check new configuration of SSH
```sh
service sshd reload
```
If that is OK, restart SSH-daemon
```sh
service sshd restart
```
#### Activate Firewall
Try to mitigate any issues otherwise, all connection get lost and the system is stuck.
So stop running PF-firewall after 5 minutes using crontab.
```sh
crontab -e
*/5 * * * *   service pf stop
```
Now check also the Firewall
```sh
kldload pf
service pf onereload
```
Then try to start the firewall.
```sh
service pf onestart
```
Now try to reconnect to the system when the firewall is active.
If this works perfectly, deactivate ``crontab`` entry and activate firewall
```sh
crontab -e
sysrc pf_enable=YES
service pf restart
```
If this ran smoothly without issues, modify rc.conf to start firewall automatically at boot time and reboot one last time
```sh
reboot
```

Don't forget to unlock the ZFS-directories after reboot
```sh
su
zfs load-key -r zroot/werzel
zfs mount zroot/werzel
```
#### Jails
If you can still connect to the system, the base install is complete so you can start installation of jails
```sh
~/server_setup/jail_creation.sh
~/server_setup/jail_certification.sh
~/server_setup/jail_templates.sh
```
Reboot your server and do any needed post installation task.

# Tips'n'tricks
## ZFS Encryption
```sh
zfs create -o encryption=[algorithm] -o keylocation=[location] -o keyformat=[format] poolname/datasetname
```
### Unmount / Unload
```sh
zfs unmount zroot/werzel
zfs unload-key -r zroot/werzel
```
### Load / Mount
```sh
zfs load-key -r zroot/werzel
zfs mount zroot/werzel
```
### Rescue
```sh
zfs load-key -r zroot/werzel
zpool import -fR /mnt
```
## GIT
### Empty Repository
```sh
git init --bare
```
## Shell
### Update / setup Shell
```sh
vi /etc/master.passwd
/usr/local/bin/zsh

pwd_mkdb -p /etc/master.passwd
```
## Portmaster
```sh
portmaster
--update-if-newer
--packages-build
--delete-build-only
-d always clean distfiles
-x avoid building
-f always rebuild
-w save shared libraries
-a all
-y | -n
--clean-distfiles
-s clean stale ports
--check-depends
```

## SSH
Create one keypair for root (su) for later use with GitHub, then logout and do the same for current user, add password to agent and restart service as root.
```sh
exit
ssh-keygen -t ed25519
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519
su
service sshd restart
```
