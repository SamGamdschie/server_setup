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

bastille cmd certbot SLEEPTIME=$(awk 'BEGIN{srand(); print int(rand()*(3600+1))}'); echo "0 0,12 * * * root sleep $SLEEPTIME && certbot renew -q" | tee -a /etc/crontab > /dev/null

# Convert Private Key and copy Certificates for MariaDB
mkdir -p /werzel/certificates/live/mysql
openssl ec -in /werzel/certificates/live/werzelserver.de/privkey.pem -out /werzel/certificates/live/mysql/privkey.pem
cp /werzel/certificates/live/werzelserver.de/fullchain.pem /werzel/certificates/live/mysql/fullchain.pem
cp /werzel/certificates/live/werzelserver.de/chain.pem /werzel/certificates/live/mysql/chain.pem
chown 88:wheel * 
