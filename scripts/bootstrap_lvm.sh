#! /bin/sh

apt-get --assume-yes install lvm2
pvcreate /dev/sdb
vgcreate lxc-vg /dev/sdb

