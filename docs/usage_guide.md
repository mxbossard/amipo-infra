User guide
======

## Guidelines
### Séparation des environnements
* development: sur le poste de dev avec vagrant.
* stagging: environnement de test similaire à la production.
* production: environnement cible, hebergent les applications.

### Container design
* 1 service par CT
* Le ct est jetable, il n'y a pas d'état à sauvegarder dans le ct. Une BD exterieur au ct est utilisée, ou bien un fs externe est monté dans le ct (on appele ça un volume).
* Par défaut il devrait y avoir au moins un volume pour recceuillir les logs.

### Procedure de déploiement
* Déploiment en dev par defaut
* Secret necessaire pour le déploiement stagging
* Secret different nécessaire pour le déploiement en production.

### Sécurité
* Les  secrets doivent etre identifiés et ne doivent pas ê̈tre partagés avec  git.




## Choix
### Ansible, Inventory, lxc
* L'accent est mis sur la simplicité d'utilisation des conteneurs.
* L'infrastructure devrait etre décrite de maniere similaire pour chaque environnement.
* Les differences entre les environnements devraient etre faible.
* Les VMs de l'environnement de dev (development) provisionnés par vagrant sont accessibles avec le suffixe .dev
* Les conteneurs LXC sont accessibles avec le suffixe .lxc
* L'environnement de dev doit pouvoir etre construit par morceau pour faciliter l'usage : par defaut lors du premier déploiement de l'environnement de dev, seul un petit noyau de l'infra est construit.
* L'inventory ansible de dev n'est pas statique du fait de cette construction par morceau. Seul les machines (conteneurs) construits sont listées par un inventory dynamique.
* Le provisioning des VM vagrant est réalisé le plus possible avec ansible. Ansible est installé dans la VM controller, des scripts sont présents pour utiliser ansible depuis le hosts via le controller qui doit etre up pour fonctionner.



## To document
* Environments
* Scripts
* Playbooks
* Inventory
* Groups
* autoBuild
* config files
* cinematic: vagrant, lxc, ssh, dns, route, ... 
* secrets ?
