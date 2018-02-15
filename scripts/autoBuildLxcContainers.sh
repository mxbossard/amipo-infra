#! /bin/sh

ansibleHome="$HOME/ansible"
inventory="$ansibleHome/amipo_infra.inventory"
playbook="$ansibleHome/playbooks/autoBuildLxcContainers.yml"

limit="$1"

if [ -z "$limit" ]
then
	>&2 echo "You must supply a limit."
	>&2 echo "usage: autoLxcBuild.sh limit"
	exit 1
fi

cd $ansibleHome
ansible-playbook -i "$inventory" -i "$ansibleHome/inventory" -e "limitPattern=$limit" $playbook

