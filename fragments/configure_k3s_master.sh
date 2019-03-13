#!/bin/sh

source /etc/heat_params

SERVER_OPTION=""
if [ $DISABLE_MASTER_AGENT = "True" ]; then
  SERVER_OPTION="--disable-agent"
fi

cat <<EOF > /etc/systemd/system/k3s-master.service
[Unit]
Description=Lightweight Kubernetes
Documentation=https://k3s.io
After=network.target

[Service]
ExecStartPre=-/sbin/modprobe br_netfilter
ExecStartPre=-/sbin/modprobe overlay
ExecStart=/usr/bin/k3s server --node-ip ${K3S_MASTER_PUBLIC_IP} --cluster-cidr ${PODS_NETWORK_CIDR} --service-cidr ${SERVICE_NETWORK_CIDR} --cluster-dns ${CLUSTER_DNS_IP} ${SERVER_OPTION}
KillMode=process
Delegate=yes
LimitNOFILE=infinity
LimitNPROC=infinity
LimitCORE=infinity
TasksMax=infinity

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable k3s-master
systemctl start k3s-master
