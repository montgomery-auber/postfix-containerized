#!/bin/sh -x
sed -i 's/dummy.float.i.ng/'"$FQDN"'/g' /etc/nginx/conf.d/default.conf
curl -X POST --unix-socket /run/docker.sock http://docker/containers/nginx/restart
