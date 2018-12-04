#! /bin/sh

# Sometimes, on vagrant up, a box may be not visible by the controller.
# To avoid network bug, this script try to awake the network between the box and the controller.
# This script need to be executed within the box

boxName="$( hostname ).dev"

echo "Trying to ssh from $boxName to controller to launch a ping from controller to $boxName ..."

while ! ssh -o StrictHostKeyChecking=no -i /vagrant/.privateCredentials/vagrant_insecure_private_key vagrant@controller.dev ping -c1 $boxName
do
	sleep 1
done

