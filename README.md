# postfix-containerized
Postfix in easy to install containers for multiple domains.
edit the files for your own use, use at your own risk!
set your DNS to point your domain to the server that will serve your email, etc. It should be an A record, though a C record might also work.
Add an MX record with your domain name pointing to the A record that you made for this server. The internet will not be able to deliver mail without MX record. Am Mx Record tells which server to deliver mail to.
change the email address in docker-files/docker-compose.yml , otherwise I will get your domain renewal reminders.  change the domain name in .env file to your domain name that you setup in DNS.
Set postgres password in line 4 of docker-files/prepare-postfix.sh
Then run:
cd docker-files
sudo bash ./prepare-postfix.sh
docker-compose up -d 
docker exec -it postfixadmin /var/www/html/scripts/postfixadmin-cli admin add YOUREMAIL@YOURDOMAIN.com  --password SECRETPASS1! --password2 SECRETPASS1! --superadmin 1 --active 1
now go to your http://yourdomain.com:8080 
login with username and secret pass that you made 
Add domains
allow present admin to edit new domains
add email boxes