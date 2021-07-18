#!/bin/sh -x
sed -i 's/dummy.float.i.ng/'"$FQDN"'/g' /etc/nginx/conf.d/default.conf
sed -i 's/dummy.float.i.ng/'"$FQDN"'/g' /etc/dovecot/dovecot.conf
sed -i 's/dummy.float.i.ng/'"$FQDN"'/g' /etc/postfix/main.cf
curl -X POST --unix-socket /run/docker.sock http://docker/containers/nginx/restart
curl -X POST --unix-socket /run/docker.sock http://docker/containers/dovecot/restart
curl -X POST --unix-socket /run/docker.sock http://docker/containers/postfix/restart