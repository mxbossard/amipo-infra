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

The additional drive on which are installed LXC is persistent. It is not destroy on vagrant destroy. To destroy it, you can remove the file located in ~/.vagrant.d/amipo1_disk_lxc.vdi but only when vagrant box amipo1 is halted or destoryed.

### Unable to resolve vagrant box names
You should be able to ping amipo1.dev and controller.dev from your host computer. If not dnsmasq is probably badly configured. You could try a `sudo service dnsmasq restart`.

## User Guide
This infra code is responsible to setup the infrastructure.

## Open questions
* Couple or not container creation to container configuration ? => Better not. It should exists some playbooks building containers, then others deploying softwares on this containers.
* How to differentiate environments (ex: ssl in dev and prod env) ? => With dedicated playbooks, we can create containers slithly deferently for each env.
* How to manage secrets ?

## TODO

## TODO Vagrant
* Accelerer l'installation d'ansible dans la vm controller
* Utiliser une cle ssh perso plutot que la cle insecure_private_key de vagrant ?


## TODO Ansible
* Verifier l'utilisation actuelle des group_vars.
* Il faudrait que 2 groupes distincts puissent definir chacun leur volumes.
* Il y a confusion entre les noms et les groupes pour les conteneurs. le ct front a pour nom front dans le groupe front. Cela n'est pas clair du coup pour le debug. Il pourrait etre judicieux de rajouter le suffix .lxc dans le nom du conteneur.
* Il faudrait se passer des fichiers dans config/
* Fournir un conteneur Frontal nginx prod ready
* Fournir un conteneur Accueil ssh (lobby) prod ready
* Passer des patterns complexes (avec or, and, ...) au builder de conteneur
* Revoir l'idempotence de l'initialisation des CT
* Comment faire pour choisir entre les protocole ssh et https pour cloner les repo si l'utilisateur ne possede pas de compte chez framagit ?


## TODO Frontal
* Fournir un SSL AC de dev qui pourra etre installer sur les postes de dev, et signer les certificats de dev du frontal.
* Monter des repertoires (log, ssl certs, ...) du host lxc dans le conteneur.


## TODO Lobby ssh
* Créer des comptes utilisateurs sur les machines
* Lister les comptes utilisateurs
* Chaque compte sur toutes les machines ?
* Généré une nouvelle clé ssh à la création de l'utilisateur
* Ou stocker les clés ? Un ct de reference ?
* Comment gérer les groupes : quel user dans quel groupe sur quelle machine ?
* La liste des users et leur groupes est un secret.


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


## Choix
### Ansible, Inventory, lxc
* L'accent est mis sur la simplicité d'utilisation des conteneurs.
* L'infrastructure devrait etre décrite de maniere similaire pour chaque environnement.
* Les differences entre les environnements devraient etre faible.
* Les VMs de l'environnement de dev provisionnés par vagrant sont accessibles avec le suffixe .dev
* Les conteneurs LXC sont accessibles avec le suffixe .lxc
* L'environnement de dev doit pouvoir etre construit par morceau pour faciliter l'usage : par defaut lors du premier déploiement de l'environnement de dev, seul un petit noyau de l'infra est construit.
* L'inventory ansible de dev n'est pas statique du fait de cette construction par morceau. Seul les machines (conteneurs) construits sont listées par un inventory dynamique.
* Le provisioning des VM vagrant est réalisé le plus possible avec ansible. Ansible est installé dans la VM controller, des scripts sont présents pour utiliser ansible depuis le hosts via le controller qui doit etre up pour fonctionner.

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

