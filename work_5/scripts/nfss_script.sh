#!/bin/bash


selinuxenabled && setenforce 0

cat >/etc/selinux/config<<__EOF
SELINUX=disabled
SELINUXTYPE=targeted
__EOF

sed -i.bak -e '/# tcp=y/a udp=y' /etc/nfs.conf

mkdir -p /nfs/upload
chmod o+w /nfs/upload

echo "/nfs *(rw,sync,root_squash)" > /etc/exports
exportfs -r

systemctl enable firewalld rpcbind nfs-server
systemctl start firewalld
firewall-cmd --permanent --add-service={mountd,rpc-bind,nfs3}
firewall-cmd --reload

systemctl start rpcbind nfs-server
systemctl enable rpcbind nfs-server

