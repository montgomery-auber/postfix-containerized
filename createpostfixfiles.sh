
cd etc/postfix
mkdir sql
PGPW="postfixadminPassword"

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

chown -R 100:101 sql
chmod 640 sql/*


