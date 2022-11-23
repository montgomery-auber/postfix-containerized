### Postfix Linux Email Server using docker-compose and scripts
You can simplify this Postfix installation by using [pre-installed EC2 ](https://aws.amazon.com/marketplace/pp/B0797V545N/ref=_PTNR_github) </br>
This release works of Postfix Linux Email Server as a full email, configured email server, with Postfix, Dovecot, Postgres, Letsencrypt Certicate and Roundcube. </br>
See official Page of Postfix Linux Email Server at our site [floatingCloud.io](http://floatingcloud.io/mail-server-linux-postfix-using-mysql-tons-users/)</br>
To use this Complete Postfix Linux Email Server:</br>
- First setup an A record and MX record that points to your server.
[http://floatingcloud.io/setup-mx-record-in-route-53-with-a-domain-that-you-registered-with-aws/](http://floatingcloud.io/setup-mx-record-in-route-53-with-a-domain-that-you-registered-with-aws/)
`cd  postfix-containerized/docker-files`
- BE SURE TO use the correct fqdn pointing to your Postfix Email Server and that it Already has MX record .
- run the command to configure your complete postfix email server:
`./prepare-postifx.sh YOUR-FULLY-QUALIFIED-DOMAIN-NAME`
- This script creates an https certificates which are used by the Dovecot IMAP server and the Roudncube webmail as well as an admin user with username admin@YOUR-FQDN .
- Open https://YOUR-FQDN the password is the Instance ID
- Postfixadmin is included for easy User Admin in Web UI, You can add users login to https://YOUR-FQDN/admin with same credentials, click on “Add Mailbox”
- Spam Protection: this Postfix Email Server also rejects known spam using "reject_rbl_client" filtering from trusted Filters.
Enjoy!
