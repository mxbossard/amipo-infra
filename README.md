AMIPO Infrastructure's code
=======

## Firstly, you need a framagit.org account preferencially with an ssh key
For now, you need an ssh access on framagit.org.
You can generate a ssh key like this: `ssh-keygen -b 4096 -t rsa -f ~/.ssh/amipo_git_key -q -N ""`.
Then you can install your key by copy pasting the content of the public certificate (~/.ssh/amipo_git_key.pub) into the framagit.irg interface available here: <a href="https://framagit.org/profile/keys">https://framagit.org/profile/keys</a>.

Our framagit.org dev group can be found here: <a href="https://framagit.org/amipo">https://framagit.org/amipo</a>.

## We use vagrant
Vagrant allow us to share our working environment easily and quickly.
Vagrant will create some Virtual Machines on your computer and emulate real production servers.
We call this VMs our dev environment.

### Vagrant plugin used
* landrush: a DNS to manage box names
* vagrant-persistent-storage: add persistent storage to virtualbox VMs

## "Easy" setup

### Clone the project
`git clone git@framagit.org:amipo/amipo-infra.git` 

`cd amipo-infra`

### Minimal installation of vagrant + virtualbox on your computer
_Manual installation described in a further chapter_

`./installVagrant.sh`

### Creation of project local test VMs with vagrant
`vagrant up`

### Test if the setup works: connect into VM controller
You should be able to browse <a href="http://amipo1.dev">http://amipo1.dev</a>

`vagrant ssh controller`

`ansible all -m ping`

## Troubleshooting problems

### Errors on vagrant up
Previous build may interfer with new ones. You can clean vagrant env by removing some content in following directories:
* .vagrant/machines/*
* ~/VirtualBox VMs/*

The additional drive on which are installed LXC is persistent. It is not destroy on vagrant destroy. To destroy it, you can remove the file located in .vagrant.d/amipo1_disk_lxc.vdi but only when vagrant box amipo1 is halted or destoryed.

### Unable to resolve vagrant box names
You should be able to ping amipo1.dev and controller.dev from your host computer. If not dnsmasq is probably badly configured. You could try a `sudo service dnsmasq restart`.

## User Guide
This infra code is responsible to setup the infrastructure.
See [User guide](docs/user_guide.md).

## TODO
See [Todo file](docs/todo.md)

## Some Documentation
* <a href="https://help.ubuntu.com/lts/serverguide/lxc.html">Setup LXC</a>
* <a href="https://stgraber.org/2014/01/17/lxc-1-0-unprivileged-containers/">Unprivileged LXC containers</a>

### Detailed setup on debian like system (not up to date)
_Download vagrant from https://www.vagrantup.com/downloads.html_

Install vagrant like this (on debian like system) : 

`sudo dpkg -i vagrant_2.0.1_x86_64.deb`

Install virtualbox, python et pip le gestionaire de packet de python:

`sudo apt install virtualbox-dkms virtualbox python2.7 python-pip libssl-dev`

Installation de ansible:

`sudo pip install --upgrade setuptools`

`sudo pip install ansible`

`vagrant plugin install landrush vagrant-persistent-storage`

