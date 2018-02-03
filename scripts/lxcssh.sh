#! /bin/sh

ansibleDir="/home/vagrant/ansible"
ctName="$1"
managerUser="manager"
managerSshKeyFile="~/.ssh/provisioning_key"

json="$(/bin/sh $ansibleDir/inventory/lxcLocalInventory.sh --host $ctName)"

ctIp="$(echo $json | sed -r -e 's/.*"([0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3})".*/\1/g')"


sshArgs="-o ControlMaster=auto -o ControlPersist=60s -o UserKnownHostsFile=/dev/null -o IdentitiesOnly=yes -o StrictHostKeyChecking=no"
ssh $sshArgs -i $managerSshKeyFile $managerUser@$ctIp

