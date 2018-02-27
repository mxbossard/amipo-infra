#! /bin/sh

inventoryScript="/home/lxc/lxcRemoteInventory.py"
lxcUser="lxc"
args="$@"

# Inventory lxc hosts with ansible
ansibleInventory() {
	lxcInventory="/home/vagrant/ansible/development_inventory/vagrant.test"
	lxcHostsGroup="lxc_host"

	ansible $lxcHostsGroup -o -i $lxcInventory --become --become-user $lxcUser -a "/bin/sh -c '$inventoryScript $args'" | grep -o -e '{.*}'
}

# Inventory lxc hosts with ssh
sshInventory() {
	sshKeyFile="/home/vagrant/.vagrantSsh/insecure_private_key"
	lxcHost="amipo1.dev"

	timeout 5 ssh -i $sshKeyFile -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o IdentitiesOnly=yes -o ControlMaster=auto -o ControlPersist=60s -o ConnectTimeout=1 $lxcHost "sudo -u $lxcUser -i /bin/sh -c '$inventoryScript $args'" || echo "{}"	
}

sshInventory
#ansibleInventory

