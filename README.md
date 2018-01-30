AMIPO Infrastructure's code
=======

## We use vagrant
Vagrant allow us to share our working environment easily and quickly.
Vagrant will create some Virtual Machines on your computer and emulate real production servers.
We call this VMs our test environment.

### Vagrant plugin used
* landrush: a DNS to manage box names
* vagrant-persistent-storage: add persistent storage to virtualbox VMs

## "Easy" setup

### Clone of the project
`git clone git@github.com:mxbossard/amipo-infra.git`

`cd amipo-infra`

### Minimal installation of vagrant + virtualbox on your computer
_Manual installation described in a further chapter_

`./installVagrant.sh`

### Creation of project local test VMs with vagrant
_During first vagrant up, vagrant may complain about SATA Controller._

`vagrant up`

### Test if the setup works: connect into VM controller
`vagrant ssh controller`

`ansible all -m ping`

## TODO Vagrant
* Faire en sorte que le DNS de landrush soit resolue directement sur le host
* Faire en sorte de resoudre les noms cours comme amipo1 plutot que amipo1.vagrant.test
* Accelerer l'installation d'ansible dans la vm controller
* Utiliser une cle ssh perso plutot que la cle insecure_private_key de vagrant ?



### Setup on debian like system
_Download vagrant from https://www.vagrantup.com/downloads.html_

Install vagrant like this (on debian like system) : 

`sudo dpkg -i vagrant_2.0.1_x86_64.deb`

Install virtualbox, python et pip le gestionaire de packet de python:

`sudo apt install virtualbox-dkms virtualbox python2.7 python-pip libssl-dev`

Installation de ansible:

`sudo pip install --upgrade setuptools`

`sudo pip install ansible`

`vagrant plugin install landrush vagrant-persistent-storage`

