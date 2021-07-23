
#/bin/bash 
set -x 
docker exec -it postfixadmin /var/www/html/scripts/postfixadmin-cli admin add admin@test.float.i.ng  --password EthanDavid11! --password2 EthanDavid11! --superadmin 1 --active 1
sleep 1
docker exec -it postfixadmin /var/www/html/scripts/postfixadmin-cli domain add  test.float.i.ng  --mailboxes 0 --active 1
sleep 1
docker exec -it postfixadmin /var/www/html/scripts/postfixadmin-cli admin update admin@test.float.i.ng --domains test.float.i.ng  
sleep 1
docker exec -it postfixadmin /var/www/html/scripts/postfixadmin-cli mailbox add steve@test.float.i.ng --password EthanDavid11! --password2 EthanDavid11!  --welcome-mail   --email-other 

