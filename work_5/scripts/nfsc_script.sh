#!/bin/bash

selinuxenabled && setenforce 0

cat >/etc/selinux/config<<__EOF
SELINUX=disabled
SELINUXTYPE=targeted
__EOF

yum install nfs-utils -y
yum install nano -y
systemctl enable firewalld --now

echo "192.168.50.10 server" >> /etc/hosts
mkdir /mnt/export
echo "server:/nfs/ /mnt/export nfs vers=3,proto=udp,noauto,x-systemd.automount 0 0" >>/etc/fstab
mount /mnt/export && touch /mnt/export/upload/file.txt
echo "test nfs" >> /mnt/export/upload/file.txt
systemctl daemon-reload
systemctl restart remote-fs.target