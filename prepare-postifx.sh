#!/bin/bash
# RUN this as root 

PGPW="notSecureChangeMe"

#Detects if script are not running as root... from https://unix.stackexchange.com/questions/443751/run-entire-bash-script-as-root-or-use-sudo-on-the-commands-that-need-it
if [ "$UID" != "0" ]; then
   #$0 is the script itself (or the command used to call it)...
   #$* parameters...
   if whereis sudo &>/dev/null; then
     echo "Please type the sudo password for the user $USER"
     sudo $0 $*
     exit
   else
     echo "Sudo not found. You will need to run this script as root."
     exit
   fi 
fi

# put install docker and compose here
#add user postfix 

mkdir -p ./etc/postfix ./var/spool/postfix ./var/spool/mail ./var/log ./var/mail ./var/mail/domains

chown -R 106:106 ./var/spool/

chown -R 105:105 ./var/mail/domains

chown root:root ./etc/postfix/dynamicmaps.cf
chmod 644 ./etc/postfix/dynamicmaps.cf


#The following needs to be owned by root
cd ./etc/postfix
#mkdir sql
#PGPW="byg2812"

cat - <<EOF >sql/pgsql_virtual_alias_domain_catchall_maps.cf
user=postfixadmin
password = $PGPW
hosts = localhost
dbname = postfixadmin
query = Select goto From alias,alias_domain where alias_domain.alias_domain = '%d' and alias.address = '@' ||  alias_domain.target_domain and alias.active = true and alias_domain.active= true 
EOF

cat - <<EOF >sql/pgsql_virtual_alias_domain_mailbox_maps.cf
user=postfixadmin
password = $PGPW
hosts = localhost
dbname = postfixadmin
query = Select maildir from mailbox,alias_domain where alias_domain.alias_domain = '%d' and mailbox.username = '%u' || '@' || alias_domain.target_domain and mailbox.active = true and alias_domain.active
EOF

cat - <<EOF >sql/pgsql_virtual_alias_domain_maps.cf
user=postfixadmin
password = $PGPW
hosts = localhost
dbname = postfixadmin
query = select goto from alias,alias_domain where alias_domain.alias_domain='%d' and alias.address = '%u' || '@' || alias_domain.target_domain and alias.active= true and alias_domain.active= true
EOF

cat - <<EOF >sql/pgsql_virtual_alias_maps.cf
user=postfixadmin
password = $PGPW
hosts = localhost
dbname = postfixadmin
query = Select goto From alias Where address='%s' and active ='1'
EOF

cat - <<EOF >sql/pgsql_virtual_domains_maps.cf
user=postfixadmin
password = $PGPW
hosts = localhost
dbname = postfixadmin
query = Select domain from domain where domain='%s' and active='1'
EOF

cat - <<EOF >sql/pgsql_virtual_mailbox_maps.cf
user=postfixadmin
password = $PGPW
hosts = localhost
dbname = postfixadmin
query = Select maildir from mailbox where username='%s' and active=true
EOF

#chown -R postfix:postfix sql
chown -R 106:106 sql
chmod 644 sql/*
#mkdir -p /opt/postfix/etc/postfix /opt/postfix/var/spool/postfix /opt/postfix/var/spool/mail /opt/postfix/var/log /opt/postfix/var/mail /opt/postfix/var/mail/domains
