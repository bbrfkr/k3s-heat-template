#!/bin/sh

source /etc/heat_params

cat <<EOF > /etc/systemd/system/k3s-master.service
[Unit]
Description=Lightweight Kubernetes
Documentation=https://k3s.io
After=network.target

[Service]
ExecStartPre=-/sbin/modprobe br_netfilter
ExecStartPre=-/sbin/modprobe overlay
ExecStart=/usr/bin/k3s server --disable-agent --node-ip ${K3S_MASTER_PUBLIC_IP}
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
