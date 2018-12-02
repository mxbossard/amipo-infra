TODO
=======

## TODO Vagrant
* Utiliser une cle ssh perso plutot que la cle insecure_private_key de vagrant ?


## TODO Ansible
* Comment faire pour choisir entre les protocole ssh et https pour cloner les repo si l'utilisateur ne possede pas de compte chez framagit ?

## TODO Lobby ssh
* Créer des comptes utilisateurs sur les machines
* Lister les comptes utilisateurs
* Chaque compte sur toutes les machines ?
* Généré une nouvelle clé ssh à la création de l'utilisateur
* Comment gérer les groupes : quel user dans quel groupe sur quelle machine ?
* La liste des users et leur groupes est un secret.


## Idees pour le partage de config
Tentative de partage de la config avec git.

Utilisation des acl pour partager le repo git au groupe adm :
sudo apk add acl
sudo setfacl -R -m g:adm:rwX /etc/nginx
sudo find /etc/nginx -type d -exec sudo setfacl -R -m d:g:adm:rwX {} \;

## Reflexions / Notes

