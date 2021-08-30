# postfix-containerized<br />
Postfix in easy to install containers for multiple domains.<br />
Includes imap server and Roundcube Webmail<br />
edit the files for your own use, use at your own risk!<br />
set your DNS to point your domain to the server that will serve your email, etc. It should be an A record, though a C record might also work.<br /> 
Add an MX record with your domain name pointing to the A record that you made for this server. The internet will not be able to deliver mail without MX record. An Mx Record tells which server to deliver mail to.<br />
When you run the docker-files/prepare-postfix.sh it creates a 90 day letsencrypt free Certificate which renews.
Password is set to the EC2 instance id , you can find it in your AWS Console, You can change this in docker-files/prepare-postfix.sh<br />
When running the prep script BE SURE to add your domain!<br />
Then run:<br />
sudo  ./prepare-postfix.sh  yourdomain.com<br />
now go to your https://yourdomain.com<br />
login to webmail with admin@yourdomain.com and secret pass that is set to the instance id, now you can send and receive email as admin<br />
Add domains and users from https://yourdomain.com/admin login with admin@yourdomain.com and password. From there you can add mailboxes and domains (that have mx records pointing there)<br />
You can use the webmail roundcube included and also connect email clients like MS outlook<br />
