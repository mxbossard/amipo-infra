#! /bin/sh

inventoryPath="$(dirname $0)"
lxcInventory="/home/vagrant/ansible/inventory/vagrant.test"

ansible lxc_hosts -o -i $lxcInventory --become --become-user lxc -a "/bin/sh -c '/home/lxc/lxcInventory.py $*'" | grep -o -e "{.*}"

