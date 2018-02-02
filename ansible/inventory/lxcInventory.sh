#! /bin/sh

inventoryScript="/home/lxc/lxcInventory.py"
lxcUser="lxc"
args="$@"

# Inventory lxc hosts with ansible
ansibleInventory() {
	lxcInventory="/home/vagrant/ansible/inventory/vagrant.test"
	lxcHostsGroup="lxc_hosts"

	ansible $lxcHostsGroup -o -i $lxcInventory --become --become-user $lxcUser -a "/bin/sh -c '$inventoryScript $args'" | grep -o -e '{.*}'
}

# Inventory lxc hosts with ssh
sshInventory() {
	sshKeyFile="~/.vagrantSsh/insecure_private_key"
	lxcHost="amipo1"
	
	ssh -i $sshKeyFile $lxcHost "sudo -u $lxcUser -i /bin/sh -c '$inventoryScript $args'"
}

sshInventory
#ansibleInventory

