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
* vagrant-hostsupdater: manage host /etc/hosts file adding VMs names and IPs 
* vagrant-vbguest: to automatically manage download and install guest additions

## "Easy" setup

### Clone the project
`git clone git@framagit.org:amipo/amipo-infra.git` 

`cd amipo-infra`

### Minimal installation of vagrant + virtualbox on your computer
The purpose of using Vagrant and Virtualbox is to share the same environment. To avoid numerous bugs and long debugging nights, I recommand you to use this software version :
* VirtualBox v5.2.22
* Vagrant v2.2.1

A setup script automate the installation of tools needed to use vagrant + virtualbox.
A setup script is hard to build and to maintain, so it may not work on your machine, and since it require root privilege, I recommand you not to use it, unless you blindly trust me.
You should jump to the manual installation chapter.

`./installVagrant.sh`

### Creation of project local test VMs with vagrant
Warning, use Vagrant require a good internet link, because vagrant need to download distributions, packages, and so on.

`vagrant up`

### Test if the setup works: connect into VM controller
You should be able to browse <a href="http://amipo1.dev">http://amipo1.dev</a>

`vagrant ssh controller`

`ansible all -m ping`

## Troubleshooting problems
It seems that some bugfix of Virtualbox are needed. We recomand you tu use a 5.2+ version.

### Hangs on vagrant up
If vagrant hang during downloading or provisioning, check your network connectivity, destroy your box and retry.

Check if you have sufficient space in your home directory (or where the box should be deployed). Usually, a couple of GB are required.

### SSH too many authentication failures
If ansible cannot do it's job because of such an error, it may be because of the ssh-agent in a bad state. Try to restart your ssh-agent. To troubleshoot further, you may try to connect to the VM yourself from the host with the following command: `ssh -vv -i ~/.vagrant.d/insecure_private_key vagrant@MACHINE_NAME`

### Errors on vagrant up
Previous build may interfer with new ones. You can clean vagrant env by removing some content in following directories:
* .vagrant/machines/*
* ~/VirtualBox VMs/*

The additional drive on which are installed LXC is persistent. It is not destroy on vagrant destroy. To destroy it, you can remove the file located in `rm ~/.vagrant.d/amipo1_disk_lxc.vdi` but only when vagrant box amipo1 is halted or destoryed.

In some cases, you may need to restart the virtualbox daemon or reboot your computer.

If vagrant hangs during VM boot, you may use the virtualbox gui to check if the VM is started or not. You also can try to ssh to the VM to check for authentication problems.

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
_Download virtualbox from https://download.virtualbox.org/virtualbox/_
Currently we use the 5.2.22 version. You need to carefully select the binary which correspond to your OS (Ubuntu, Debian, CentOS, ...).

Install virtualbox with dpkg like this (on debian like system) :
`sudo dpkg -i DEB_FILE_I_JUST_DOWNLOADED`

_Download vagrant from https://www.vagrantup.com/downloads.html_
Currently we use the 2.2.1 version.

Install vagrant with dpkg like this (on debian like system) : 
`sudo dpkg -i DEB_FILE_I_JUST_DOWNLOADED`

Install vagrant plugins like this :
`vagrant plugin install landrush vagrant-persistent-storage vagrant-hostsupdater vagrant-vbguest`

