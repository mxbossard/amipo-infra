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

The additional drive on which are installed LXC is persistent. It is not destroy on vagrant destroy. To destroy it, you can remove the file located in ~/.vagrant/amipo1_disk_lxc.vdi but only when vagrant box amipo1 is halted or destoryed.

### Unable to resolve vagrant box names
You should be able to ping amipo1.dev and controller.dev from your host computer. If not dnsmasq is probably badly configured. You could try a `sudo service dnsmasq restart`.

## User Guide
This infra code is responsible to setup the infrastructure.

## Open questions
* Couple or not container creation to container configuration ? => Better not. It should exists some playbooks building containers, then others deploying softwares on this containers.
* How to differentiate environments (ex: ssl in dev and prod env) ? => With dedicated playbooks, we can create containers slithly deferently for each env.
* How to manage secrets ?

## TODO
* Migrate this repo from github.io to framagit.org


## TODO Vagrant
* Accelerer l'installation d'ansible dans la vm controller
* Etudier la possibilité de provisionner avec ansible chaque vagrant box independament en passant par le controller
* Utiliser une cle ssh perso plutot que la cle insecure_private_key de vagrant ?


## TODO Ansible
* Découpler la création des conteneur de la configuration des conteneurs.
* Créer un playbooks de creation de l'infra: It should ping for each needed containers, then start or create needed ones. It should expose a mean to build only few containers. Idées: pour chaque env on liste les CT (avec la distrib et la config du CT si besoin groups, volumes,... ?) Lorsque je lance un playbook sur le group frontal, ansible check si tous les CT de la liste sont up and running avant de jouer le playbook.
* Revoir l'idempotence de l'initialisation des CT
* Configurer les CT pour monter des repertoires du host dans les conteneurs.
* Fournir un conteneur Frontal nginx prod ready
* Fournir un conteneur Accueil ssh (lobby) prod ready
* Pour le moment, l'utilsateur a besoin d'avoir les access au framagit Amipo pour créer le frontal. Il faudrait voir si on peut faire mieux. Pour le moment c'est impossible, car le repo de la config nginx est privé. Quand il sera public, on devrait pouvoir contourner le problème avec un checkout du projet via le protocol https si l'utilisateur ne possede pas de compte chez framagit.


## TODO Frontal
* Fournir un SSL AC de dev qui pourra etre installer sur les postes de dev, et signer les certificats de dev du frontal.
* Monter des repertoires (log, ssl certs, ...) du host lxc dans le conteneur.


## Some Documentation
* <a href="https://help.ubuntu.com/lts/serverguide/lxc.html">Setup LXC</a>
* <a href="https://stgraber.org/2014/01/17/lxc-1-0-unprivileged-containers/">Unprivileged LXC containers</a>


## Idees pour le partage de config
Tentative de partage de la config avec git.

Utilisation des acl pour partager le repo git au groupe adm :
sudo apk add acl
sudo setfacl -R -m g:adm:rwX /etc/nginx
sudo find /etc/nginx -type d -exec sudo setfacl -R -m d:g:adm:rwX {} \;

## Reflexions / Notes

### Pour delayer la création des CT à la demande lors du lancement des playbooks
* Construire un inventory ansible complet. Lorsqu'on lance un playbook, un hook (?) s'occupe de faire en sorte que tous les CT existent, ont la bonne config (distrib, version, ...) et soient démarrés. Le hic c'est que cela peut faire doublon avec l'inventaire dynamic basé sur lxc-ls, il faut vérifier que ce ne soit pas incompatible. => Ca à l'air compatible, je pars la dessus.

* Décrire l'infra dans un fichier de config. Construire un playbook qui determine la liste des CT cible en fonction du fichier de config, puis verifie leur existance, ...

## Choix
### Ansible, Inventory, lxc
* L'accent est mis sur la simplicité d'utilisation des conteneurs.
* L'infrastructure devrait etre décrite de maniere similaire pour chaque environnement.
* Les differences entre les environnements devraient etre faible.
* Les VMs de l'environnement de dev provisionnés par vagrant sont accessibles avec le suffixe .dev
* Les conteneurs LXC sont accessibles avec le suffixe .lxc
* L'environnement de dev doit pouvoir etre construit par morceau pour faciliter l'usage : par defaut lors du premier déploiement de l'environnement de dev, seul un petit noyau de l'infra est construit.
* L'inventory ansible de dev n'est pas statique du fait de cette construction par morceau. Seul les machines (conteneurs) construits sont listées par un inventory dynamique.

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

