User guide
======

## Guidelines
### Séparation des environnements
* development (dev): sur le poste de dev avec vagrant.
* stagging (stage): environnement de test similaire à la production.
* production (prod): environnement cible, hebergent les applications.

### Procedure de déploiement
* Déploiment en dev par defaut
* Secret necessaire pour le déploiement stagging: un user et une ssh private key a fournir dans .privateCredentials
* Secret different nécessaire pour le déploiement en production.

### Sécurité
Les secrets necessaires sont:
* un username ssh
* une clef privee ssh

Ils doivent etre configures pour chaque environnement dans le fichier .privateCredentials/ssh_credentials.yml, et les clefs privees ssh doivent etre deposes dans le dossier .privateCredentials/ Ce dossier contient des secrets personnels et ne devra donc jamais etre commit.


## Choix
### Ansible, Inventory, lxc
* L'infrastructure devrait etre décrite de maniere similaire pour chaque environnement.
* Les differences entre les environnements devraient etre faible.
* Les VMs de l'environnement de dev (development) provisionnés par vagrant sont accessibles avec le suffixe .dev
* L'environnement de dev doit pouvoir etre construit par morceau pour faciliter l'usage : par defaut lors du premier déploiement de l'environnement de dev, seul un petit noyau de l'infra est construit.
* Le provisioning des VM vagrant est réalisé le plus possible avec ansible. Ansible est installé dans la VM controller, des scripts présents dans le repertoire scripts/ permettent d'utiliser ansible depuis le hosts via le controller qui doit etre up pour fonctionner.


## To document
* Environments
* Scripts
* Playbooks
* Inventory
* Groups
* config files
* secrets
