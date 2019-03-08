#!/bin/sh

source /etc/heat_params

cat <<EOF > /etc/rsyncd.secrets
${NODE_TOKEN_SHARE_USER}:${NODE_TOKEN_SHARE_SECRET}
EOF

chmod 600 /etc/rsyncd.secrets

cat <<EOF > /etc/rsyncd.conf
uid           = root
gid           = root
log file      = /var/log/rsyncd.log
pid file      = /var/run/rsyncd.pid

[node-token]
        comment      = node-token share server
        path         = /var/lib/rancher/k3s/server
        auth users   = ${NODE_TOKEN_SHARE_USER}
        secrets file = /etc/rsyncd.secrets
        read only    = true
        exclude      = *
        include      = node-token
EOF

COMMAND_STATUS=1
until [ $COMMAND_STATUS -eq 0 ]; do
  ls -1 /var/lib/rancher/k3s/server/node-token
  COMMAND_STATUS=$?
  sleep 1
done

systemctl enable rsyncd
systemctl start rsyncd
