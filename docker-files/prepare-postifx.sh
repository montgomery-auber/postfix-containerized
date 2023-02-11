#!/bin/bash
set -x
# Redirect all output to logfile.txt
exec > >(tee -a floating-postfix-install.log) 2>&1

# RUN this as root 
PGPW=$(/usr/bin/curl -s http://169.254.169.254/latest/meta-data/instance-id)
if [ $# -eq 0 ]; then
    echo "No arguments provided"
    exit 1
fi
if (( EUID != 0 )); then
    echo "You must be root to do this." 1>&2
    exit 1
fi
# Change file names, so that after git pull config files wont be overwritten with dummy domain
sudo cp ../docker-volumes/etc/nginx/conf.d/default.conf.dummy ../docker-volumes/etc/nginx/conf.d/default.conf
sudo cp ../docker-volumes/etc/dovecot/dovecot.conf.dummy  ../docker-volumes/etc/dovecot/dovecot.conf
sudo cp ../docker-volumes/etc/postfix/main.cf.dummy ../docker-volumes/etc/postfix/main.cf
# Remove postfix if it's installed, it takes the needed ports
sudo yum remove postfix -y
#make sure tree structure and privleges are correct

#create .env file for fqdn and password
sudo cat - <<EOF > .env
FQDN=$1
PGPW=$PGPW
FLOATING_POSTFIX_VERSION=3.7.4
EOF
#sudo yum update -y
cd ../docker-volumes
sudo mkdir -p ./etc/postfix ./var/spool/postfix/private ./etc/dovecot ./var/log ./var/mail ./var/mail/domains ./var/lib/postgresql/data ./var/log/dovecot
sudo rm -rf ./var/lib/postgresql/data/.gitignore
sudo chown -R root:105 ./var/spool/postfix 
sudo chmod -R 770 ./var/spool/postfix 
sudo chown -R root:105 ./etc/postfix/ 
sudo chmod 750 ./etc/postfix/  
sudo chmod 644 ./etc/postfix/dynamicmaps.cf 
sudo chown -R 105:106 ./var/mail/domains
# Create files connecting postfix and dovecot to postgres
cd etc/postfix
sudo cat - <<EOF >sql/pgsql_virtual_alias_domain_catchall_maps.cf
user=postfixadmin
password = $PGPW
hosts = pgsql
dbname = postfixadmin
query = Select goto From alias,alias_domain where alias_domain.alias_domain = '%d' and alias.address = '@' ||  alias_domain.target_domain and alias.active = true and alias_domain.active= true 
EOF
sudo cat - <<EOF >sql/pgsql_virtual_alias_domain_mailbox_maps.cf
user=postfixadmin
password = $PGPW
hosts = pgsql
dbname = postfixadmin
query = Select maildir from mailbox,alias_domain where alias_domain.alias_domain = '%d' and mailbox.username = '%u' || '@' || alias_domain.target_domain and mailbox.active = true and alias_domain.active
EOF
sudo cat - <<EOF >sql/pgsql_virtual_alias_domain_maps.cf
user=postfixadmin
password = $PGPW
hosts = pgsql
dbname = postfixadmin
query = select goto from alias,alias_domain where alias_domain.alias_domain='%d' and alias.address = '%u' || '@' || alias_domain.target_domain and alias.active= true and alias_domain.active= true
EOF
sudo cat - <<EOF >sql/pgsql_virtual_alias_maps.cf
user=postfixadmin
password = $PGPW
hosts = pgsql
dbname = postfixadmin
query = Select goto From alias Where address='%s' and active ='1'
EOF
sudo cat - <<EOF >sql/pgsql_virtual_domains_maps.cf
user=postfixadmin
password = $PGPW 
hosts = pgsql
dbname = postfixadmin
query = Select domain from domain where domain='%s' and active='1'
EOF
sudo cat - <<EOF >sql/pgsql_virtual_mailbox_maps.cf
user=postfixadmin
password = $PGPW
hosts = pgsql
dbname = postfixadmin
query = Select maildir from mailbox where username='%s' and active=true
EOF
sudo chown -R root:105  sql
sudo chmod  -R 750 sql
##Add Dovecot 
cd ..
#Create the /etc/dovecot/dovecot-pgsql.conf file:
sudo cat - <<EOF >dovecot/dovecot-pgsql.conf
driver = pgsql
connect = host=pgsql dbname=postfixadmin user=postfixadmin password=$PGPW
password_query = select username,password from mailbox where local_part = '%n' and domain = '%d'
default_pass_scheme =  SHA512-CRYPT
EOF

sudo chown root:105 dovecot/dovecot-pgsql.conf
sudo chmod 750 dovecot/dovecot-pgsql.conf
chown -R root:105 ../var/log/dovecot
cd ../../docker-files
docker compose up -d 
sleep 90
docker exec pgsql  psql "postgresql://postfixadmin:$PGPW@pgsql:5432/postfixadmin" -c 'CREATE USER postgres SUPERUSER'
docker exec -it postfixadmin /var/www/html/scripts/postfixadmin-cli admin add admin@$1  --password $PGPW --password2 $PGPW --superadmin 1 --active 1
sleep 1
docker exec -it postfixadmin /var/www/html/scripts/postfixadmin-cli domain add  $1  --mailboxes 0 --active 1
sleep 1
docker exec -it postfixadmin /var/www/html/scripts/postfixadmin-cli admin update admin@$1 --domains $1 
sleep 1
docker exec -it postfixadmin /var/www/html/scripts/postfixadmin-cli mailbox add admin@$1 --password $PGPW --password2 $PGPW  --welcome-mail   --email-other 
cp ../docker-volumes/etc/letsencrypt/keys/.gitignore ../docker-volumes/var/lib/postgresql/data/.gitignore
