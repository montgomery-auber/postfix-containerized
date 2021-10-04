### Postfix Email Server using docker-compose and scripts
You can simplify this installation by using [pre-installed EC2 ](https://aws.amazon.com/marketplace/pp/B0797V545N/ref=_PTNR_github) </br>
This release works as a full email, configured email server, with Postfix, Dovecot, Postgres, Letsencrypt Certicate and Roundcube. </br>
See official Page at our site [floatingCloud.io](http://floatingcloud.io/mail-server-linux-postfix-using-mysql-tons-users/)</br>
To use this:</br>
- first setup an A record and MX record that points to your server.
[http://floatingcloud.io/setup-mx-record-in-route-53-with-a-domain-that-you-registered-with-aws/](http://floatingcloud.io/setup-mx-record-in-route-53-with-a-domain-that-you-registered-with-aws/)
`cd  postfix-containerized/docker-files`
- BE SURE TO use the correct fqdn and that it Already has MX record .
- run the command:
`./prepare-postifx.sh YOUR-FULLY-QUALIFIED-DOMAIN-NAME`
- This script creates an https certificates which are used by the mail server and the webmail as well as an admin user with username admin@YOUR-FQDN .
- Open https://YOUR-FQDN the password is the Instance ID
- To add users login to https://YOUR-FQDN/admin with same credentials, click on “Add Mailbox”

Enjoy!
