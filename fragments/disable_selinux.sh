#!/bin/sh

sed -i 's/^SELINUX=.*/SELINUX=permissive/g' /etc/selinux/config

setenforce 0
