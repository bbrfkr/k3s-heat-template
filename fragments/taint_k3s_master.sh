#!/bin/sh

source /etc/heat_params

wget -O /usr/bin/yq https://github.com/mikefarah/yq/releases/download/2.2.1/yq_linux_amd64
chmod +x /usr/bin/yq

CA_CERT=$(mktemp)
yq r /etc/rancher/k3s/k3s.yaml clusters.0.cluster.certificate-authority-data | base64 -d - > $CA_CERT
USERNAME=$(yq r /etc/rancher/k3s/k3s.yaml users.0.user.username)
PASSWORD=$(yq r /etc/rancher/k3s/k3s.yaml users.0.user.password)

# wait for API server being started
until  [ "ok" = "$(curl -u $USERNAME:$PASSWORD --cacert $CA_CERT https://127.0.0.1:6443/healthz)" ]
do
    echo "Waiting for Kubernetes API..."
    sleep 5
done

if [ "False" = "${DISABLE_MASTER_AGENT}" ]; then
  k3s kubectl label node $(hostname) node-role.kubernetes.io/master=""
  k3s kubectl taint node $(hostname) node-role.kubernetes.io/master=:NoSchedule
fi
