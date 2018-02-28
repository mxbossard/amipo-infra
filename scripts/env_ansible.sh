scriptDir="$(dirname $(readlink -f $0))"
ansibleDir="$(readlink -f $scriptDir/../ansible)/"
cd $scriptDir/..

# Vagrant ansible provider check if the inventory and the playbook exists on the host. So we need to rewrite the command
command="PYTHONUNBUFFERED=1 ANSIBLE_FORCE_COLOR=true ANSIBLE_HOST_KEY_CHECKING=false ANSIBLE_SSH_ARGS='-o UserKnownHostsFile=/dev/null -o IdentitiesOnly=yes -o ControlMaster=auto -o ControlPersist=1s -o ServerAliveInterval=2 -o ServerAliveCountMax=5' $@"

# Remove inventory file wich is supplied by ansible.cfg ; keep only de basename of the playbook
cleanedCommand=$(echo $command | sed -r -e 's/--inventory-file=[^ ]*//' -e "s|$ansibleDir||")

export ansible_cleaned_command="$cleanedCommand"

