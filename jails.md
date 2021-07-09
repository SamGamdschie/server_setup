# Jails
## Basis-Installation
### iocage
ACHTUNG: Python Version! 3.6, 3.7, ...
```sh 
pkg search iocage 
pkg install py37-iocage
iocage activate 
iocage fetch 
vi /etc/fstab
fdescfs /dev/fd fdescfs rw  0   0
```

### Erstellung von Jails
```sh  
iocage create -r LATEST --name db.jails.werzelserver.de 
iocage set ip4_addr="lo0|10.0.10.1/24" db.jails.werzelserver.de
iocage start db
iocage exec db ifconfig

iocage create -r LATEST --name mail.werzelserver.de
iocage set ip4_addr="lo0|10.0.10.2/24" mail.werzelserver.de

iocage create -r LATEST --name proxy.jails.werzelserver.de
iocage set ip4_addr="lo0|10.0.10.3/24" proxy.jails.werzelserver.de

iocage create -r LATEST --name www.jails.werzelserver.de
iocage set ip4_addr="lo0|10.0.10.4/24" www.jails.werzelserver.de

iocage create -r LATEST --name secure.jails.werzelserver.de
iocage set ip4_addr="lo0|10.0.10.5/24" secure.jails.werzelserver.de

iocage create -r LATEST --name admin.jails.werzelserver.de
iocage set ip4_addr="lo0|10.0.10.6/24" admin.jails.werzelserver.de

iocage create -r LATEST --name certs.jails.werzelserver.de
iocage set ip4_addr="lo0|10.0.10.7/24" certs.jails.werzelserver.de

iocage list
```

## Jail Konfiguration
### DB
```sh  

```
### MAIL
```sh  

```
### PROXY
```sh  

```
### DB
```sh  

```

### Basis Tools
```sh  
iocage chroot <name>
iocage console <name>
iocage restart -s
iocage update <name>
iocage upgrade -r <release> <name>
```