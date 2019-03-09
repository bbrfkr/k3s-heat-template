#!/bin/sh

source /etc/heat_params

if [ $DISABLE_MASTER_AGENT = "True" ]; then
  cat <<EOF > /etc/systemd/system/k3s-master.service
[Unit]
Description=Lightweight Kubernetes
Documentation=https://k3s.io
After=network.target

[Service]
ExecStartPre=-/sbin/modprobe br_netfilter
ExecStartPre=-/sbin/modprobe overlay
ExecStart=/usr/bin/k3s server --node-ip ${K3S_MASTER_PUBLIC_IP} --cluster-cidr ${PODS_NETWORK_CIDR} --disable-agent
KillMode=process
Delegate=yes
LimitNOFILE=infinity
LimitNPROC=infinity
LimitCORE=infinity
TasksMax=infinity

[Install]
WantedBy=multi-user.target
EOF
fi

if [ $DISABLE_MASTER_AGENT = "False" ]; then
  cat <<EOF > /etc/systemd/system/k3s-master.service
[Unit]
Description=Lightweight Kubernetes
Documentation=https://k3s.io
After=network.target

[Service]
ExecStartPre=-/sbin/modprobe br_netfilter
ExecStartPre=-/sbin/modprobe overlay
ExecStart=/usr/bin/k3s server --node-ip ${K3S_MASTER_PUBLIC_IP} --cluster-cidr ${PODS_NETWORK_CIDR}
KillMode=process
Delegate=yes
LimitNOFILE=infinity
LimitNPROC=infinity
LimitCORE=infinity
TasksMax=infinity

[Install]
WantedBy=multi-user.target
EOF
fi

systemctl daemon-reload
systemctl enable k3s-master
systemctl start k3s-master
