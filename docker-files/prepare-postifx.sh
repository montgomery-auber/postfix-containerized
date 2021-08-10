#!/bin/bash
set -x
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
sudo yum remove postfix -y
cd ../docker-volumes
sudo mkdir -p ./etc/postfix ./var/spool/postfix ./etc/dovecot ./var/log ./var/mail ./var/mail/domains 
#chown -R 106:106 ./var/spool/
sudo chmod 640  ./etc/postfix/
sudo chown -R 106:106 ./var/mail/domains ./var/log/dovecot* 
sudo chmod 644 ./var/log/dovecot* 

#vmail:postdrop
#chown root:root ./etc/postfix/dynamicmaps.cf
#chmod 644 ./etc/postfix/dynamicmaps.cf
#The following needs to be owned by root
sudo chown -R root:root ./var/spool/postfix ./etc/postfix/ 
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
#chown -R postfix:postfix sql
sudo chown -R 106:106 sql
#sudo chown -R root:root sql

sudo chmod  -R 777 sql

##Add Dovecot 
cd ..
#Create the /etc/dovecot/dovecot-sql.conf file:
sudo cat - <<EOF > dovecot/dovecot-pgsql.conf
driver = pgsql
connect = host=pgsql dbname=postfixadmin user=postfixadmin password=$PGPW
password_query = select username as user, password, 1006 as userdb_uid, 1006 as userdb_gid, '*:bytes=' || quota as userdb_quota_rule from mailbox  where local_part = '%n' and domain = '%d'
user_query = select '/var/mail/domains/' || maildir as home, 1006 as uid, 1006 as gid, '*:bytes=' || quota  as quota_rule from mailbox where local_part = '%n' and domain ='%d'
default_pass_scheme =  SHA512-CRYPT
EOF
#Create dovecot quota file
sudo cat - <<EOF > dovecot/dovecot-dict-quota.conf
connect = host=pgsql dbname=postfixadmin user=postfixadmin password=$PGPW
map {
        pattern = priv/quota/storage
        table = quota2
        username_field =username
        value_field = bytes
}
map {
       pattern= priv/quota/messages
       table = quota2
       username_field = username
       value_field = messages
}
EOF
sudo chown 107:root dovecot/dovecot-pgsql.conf dovecot/dovecot-dict-quota.conf
sudo chmod 600 dovecot/dovecot-pgsql.conf dovecot/dovecot-dict-quota.conf
