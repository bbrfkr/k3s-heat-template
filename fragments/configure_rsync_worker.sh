#!/bin/sh

source /etc/heat_params

cat <<EOF > /etc/rsync.passwd
${NODE_TOKEN_SHARE_SECRET}
EOF

chmod 600 /etc/rsync.passwd

mkdir -p /etc/rancher/k3s/

COMMAND_STATUS=1
until [ $COMMAND_STATUS -eq 0 ]; do
  rsync -avz --password-file=/etc/rsync.passwd rsync://${NODE_TOKEN_SHARE_USER}@${K3S_MASTER_PRIVATE_IP}/node-token /etc/rancher/k3s
  COMMAND_STATUS=$?
  sleep 1
done
