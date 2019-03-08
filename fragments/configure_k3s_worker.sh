#!/bin/sh

source /etc/heat_params

cat <<EOF > /etc/systemd/system/k3s-worker.service
[Unit]
Description=Lightweight Kubernetes
Documentation=https://k3s.io
After=network.target

[Service]
ExecStartPre=-/sbin/modprobe br_netfilter
ExecStartPre=-/sbin/modprobe overlay
ExecStart=/usr/bin/k3s agent --server https://${K3S_MASTER_PUBLIC_IP}:6443 --token $(cat /etc/rancher/k3s/node-token)
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
systemctl enable k3s-worker
systemctl start k3s-worker
