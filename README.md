AMIPO Infrastructure's code
=======

## Setup on debian like system
Download vagrant from https://www.vagrantup.com/downloads.html

Install vagrant like this (on debian like system) : 

sudo dpkg -i vagrant_2.0.1_x86_64.deb

Install virtualbox, python et pip le gestionaire de packet de python:

sudo apt install virtualbox-dkms virtualbox python2.7 python-pip libssl-dev

Installation de ansible:

sudo pip install --upgrade setuptools
sudo pip install ansible

## Clone of the project
git clone git@github.com:mxbossard/amipo-infra.git
cd amipo-infra

## Creation de la VM avec vagrant
vagrant up

## Test if the setup works
ansible test -m ping

## Pour se connecter via ssh dans la VM (amipo1.vagrant)
vagrant ssh amipo1.vagrant
