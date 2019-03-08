#!/bin/sh

source /etc/heat_params

rpm -qa | grep wget
if [ $? -ne 0 ]; then
  yum -y install wget
fi

wget -O /usr/bin/k3s ${K3S_BINARY_URL}
chmod +x /usr/bin/k3s
