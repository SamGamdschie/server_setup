#!/bin/sh

## Templates ##
# Certificates
bastille template certbot SamGamdschie/bastille-letsencrypt

# Create all DH parameters & certificates, this will take time!
openssl dhparam -out /werzel/certificates/mail.werzelserver.de.1024.pem 2048
openssl dhparam -out /werzel/certificates/mail.werzelserver.de.dhparam.pem 4096
openssl dhparam -out /werzel/certificates/k5sch3l.werzelserver.de.dhparam.pem 4096
openssl dhparam -out /werzel/certificates/werzelserver.de.dhparam.pem 4096
openssl dhparam -out /werzel/certificates/werzel.de.dhparam.pem 4096
openssl dhparam -out /werzel/certificates/hobbingen.de.dhparam.pem 4096
openssl dhparam -out /werzel/certificates/seeadler.org.dhparam.pem 4096
bastille cmd certbot certbot register --agree-tos -m 'letsencrypt@werzelserver.de'
bastille cmd certbot certbot certonly -a dns-inwx -d 'werzelserver.de' -d '*.werzelserver.de' 
bastille cmd certbot certbot certonly -a dns-inwx -d 'mail.werzelserver.de' -d 'mail.werzel.de'
bastille cmd certbot certbot certonly -a dns-inwx -d 'werzel.de' -d '*.werzel.de' 
bastille cmd certbot certbot certonly -a dns-inwx -d 'hobbingen.de' -d '*.hobbingen.de' 
bastille cmd certbot certbot certonly -a dns-inwx -d 'seeadler.org' -d '*.seeadler.org'
