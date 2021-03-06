# Werzelserver
## Vorinstallation Löschen
```sh  
kldload zfs
kldload aesni
gmirror load
sysctl kern.geom.label.gptid.enable=0
zpool import -o readonly=on -fR /mnt zroot
zpool destroy zroot

gpart destroy -F nvd0
gpart destroy -F nvd1
```
## Grundinstallation
Rescue-System 11.2
12.0 > 64bit > mail.werzelserver.de > UFS mit 40 GB auf nvd0
```sh
bsdinstallimage
```

sshd, ntpd instalieren  
Benutzer thorsten anlegen und root mit neuem Passwort versehen

```sh
/sbin/shutdown -r now

gpart create -s gpt nvd1

/usr/sbin/freebsd-update upgrade -r 12.1-RELEASE
/usr/sbin/freebsd-update install
/sbin/shutdown -r now
/usr/sbin/freebsd-update install

/usr/sbin/pkg install -y ca_root_nss
/usr/sbin/pkg install -y subversion
/usr/sbin/pkg install -y portmaster
/usr/sbin/pkg install -y mosh
/usr/sbin/pkg install -y zsh

portsnap fetch
portsnap extract
portsnap fetch update

rm -rf /usr/src/* /usr/src/.*
svn checkout https://svn.freebsd.org/base/releng/12.1/ /usr/src
svn update /usr/src

etcupdate
pwd_mkdb -p /etc/master.passwd



```

After you compiled and installed a new version of FreeBSD, use etcupdate(8) to merge
configuration updates.
Run "etcupdate extract" once when your sources match your running system, then run
"etcupdate" after every upgrade and "etcupdate resolve" to resolve any conflicts.

### Partitionierung der ZFS-Platte
```sh  
kldload zfs
kldload aesni
sysctl kern.geom.label.gptid.enable=0

#gpart create -s gpt nvd0
#gpart create -s gpt nvd1
#gpart add -s 512K -t freebsd-boot nvd0
#gpart add -s 30G -t freebsd-zfs -l zroot0 nvd0
gpart add -t freebsd-zfs -l zwerzel0 nvd0
gpart add -s 512K -t freebsd-boot nvd1
gpart add -s 40G -t freebsd-ufs -l ufs-root1 nvd1
gpart add -t freebsd-zfs -l zwerzel1 nvd1

gpart show nvd0 nvd1

echo 'zfs_load="YES"\
geom_eli_load="YES"\
aesni_load="YES"' >> /boot/loader.conf

echo 'zfs_enable="YES"' >>  /etc/rc.conf

echo 'daily_status_zfs_enable="YES"' >> /etc/periodic.conf

geli init -e AES-XTS -l 256 /dev/gpt/zwerzel0
geli init -e AES-XTS -l 256 /dev/gpt/zwerzel1
geli attach /dev/gpt/zwerzel0
geli attach /dev/gpt/zwerzel1
mkdir /werzel

zpool create -m /werzel zwerzel mirror gpt/zwerzel0.eli gpt/zwerzel1.eli
zfs set checksum=fletcher4 zwerzel
zfs set atime=off zwerzel
zfs set compression=on zwerzel

#zfs create -o compression=off  -o exec=off -o setuid=off zwerzel
zfs create                     -o exec=off -o setuid=off zwerzel/certificates
zfs create                     -o exec=off -o setuid=off zwerzel/git
zfs create                     -o exec=off -o setuid=off zwerzel/nginx_config
zfs create                                               zwerzel/jails
```
Metadata backup for provider /dev/gpt/zwerzel0 can be found in /var/backups/gpt_zwerzel0.eli and can be restored with the following command:
```sh
geli restore /var/backups/gpt_zwerzel0.eli /dev/gpt/zwerzel0
```

## SSH
### SSH absichern
```sh
echo '## NEW SECURE SECURE SHELL\
Protocol 2\
Port 2345\
ListenAddress 78.46.50.18\
\
HostKey /etc/ssh/ssh_host_ed25519_key\
HostKey /etc/ssh/ssh_host_rsa_key\
\
KexAlgorithms curve25519-sha256@libssh.org,diffie-hellman-group-exchange-sha256\
Ciphers chacha20-poly1305@openssh.com,aes256-gcm@openssh.com,aes128-gcm@openssh.com,aes256-ctr,aes192-ctr,aes128-ctr\
MACs hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com,umac-128-etm@openssh.com\
\
# Root login is not allowed for auditing reasons.\
PermitRootLogin no\
AllowGroups wheel\
#AuthenticationMethods publickey\
\
# LogLevel VERBOSE logs users key fingerprint on login. Needed to have a clear audit track of which key was using to log in.\
LogLevel VERBOSE\
\
Subsystem       sftp    /usr/libexec/sftp-server\  -f AUTHPRIV -l INFO\' >> /etc/ssh/sshd_config
```

### SSH KeyGen
Passwort setzen!
Das Passwort kann der SSH-Agent im Speicher halten, niemals ohne!
```sh
ssh-keygen -t ed25519 -o -a 100
```

## GIT Repositories
### Basis Installation
```sh
pkg install -y git rsync
```
### GIT kopieren
```sh
rsync -avz -e "ssh -p 2345" thorsten@werzel.de:/werzel/git/ /werzel/git/
chown -R thorsten:staff /Werze/git/*
```
### GIT anlegen
```sh
git init --bare
```

### Lokale GIT-Repositories erstellen
####
```sh
mkdir -p /werzel/mail_config
cd /werzel/mail_config
git clone file:///werzel/git/mail_config.git


mkdir -p /werzel/nginx_config
cd /werzel/nginx_config
git clone file:///werzel/git/nginx_config.git

cd /root/
git clone file:///werzel/git/dotfiles.git

```
### Shell einrichten
```sh
vi /etc/master.passwd
/usr/local/bin/zsh

pwd_mkdb -p /etc/master.passwd
```

## Portmaster
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

## ADD-ONs
### Bootcode mit ZFS
```sh
gpart bootcode -b /boot/pmbr -p /boot/gptzfsboot -i 1 nvd0
gpart bootcode -b /boot/pmbr -p /boot/gptzfsboot -i 1 nvd1

echo 'vfs.root.mountfrom="zfs:zroot"\
geom_eli_load="YES"' >> boot/loader.conf
```

### ZFS
```sh
zpool create -m / -R /mnt zroot mirror gpt/zroot0 gpt/zroot1
zpool create -m / -R /mnt zroot mirror gpt/zroot0 gpt/zroot1
## Check for existing pool after rewrite

zfs set checksum=fletcher4 zroot
zfs set atime=off zroot
zfs set compression=on zroot

zfs create                     -o exec=on  -o setuid=off zroot/tmp
zfs create                                               zroot/home
zfs create                                               zroot/usr
zfs create -o compression=lz4              -o setuid=off zroot/usr/ports
zfs create -o compression=off  -o exec=off -o setuid=off zroot/usr/ports/distfiles
zfs create -o compression=off  -o exec=off -o setuid=off zroot/usr/ports/packages
zfs create -o compression=lz4  -o exec=off -o setuid=off zroot/usr/src
zfs create                                               zroot/var
zfs create -o compression=lz4  -o exec=off -o setuid=off zroot/var/crash
zfs create                     -o exec=off -o setuid=off zroot/var/db
zfs create -o compression=lz4  -o exec=on  -o setuid=off zroot/var/db/pkg
zfs create                     -o exec=off -o setuid=off zroot/var/empty
zfs create -o compression=lz4  -o exec=off -o setuid=off zroot/var/log
zfs create -o compression=gzip -o exec=off -o setuid=off zroot/var/mail
zfs create                     -o exec=off -o setuid=off zroot/var/run
zfs create -o compression=lz4  -o exec=on  -o setuid=off zroot/var/tmp
```

### ZFS - Rescue
```sh  
zpool import -fR /mnt
```
