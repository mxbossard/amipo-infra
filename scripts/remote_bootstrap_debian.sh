#! /bin/sh

# Bootstrap a remote debian server

# usage: command sshHost adminUsername sshPubKeyFilepath

sshHost="$1"
adminUsername="$2"
sshPubKeyFilepath="$3"
scriptDir="$(dirname $(readlink -f $0))"

usage() {
	>&2 echo "usage: $0 sshHost adminUsername sshPubKeyFilepath"
	>&2 echo "\tsshHost: name of host to connect. May be a host configured in .ssh/config"
	>&2 echo "\tadminUsername: user name of administrator to create"
	>&2 echo "\tsshPubKeyFilepath: admin ssh pub key file to deploy"
}

if [ -z "$sshHost" ] || [ -z "$adminUsername" ] || [ -z "$sshPubKeyFilepath" ]
then
	usage
	exit 1
fi

if [ ! -f $sshPubKeyFilepath ]
then
	>&2 echo "File $sshPubKeyFilepath does not exists !"
	usage
	exit 1
fi

if [ "root" = "$adminUsername" ]
then
	>&2 echo "adminUsername cannot be root !"
	usage
	exit 1
fi

remoteExec="ssh $sshHost /bin/sh -e"

bootstrap_ansible_script="bootstrap_ansible_debian.sh"
bootstrap_admin_script="bootstrap_admin_user_debian.sh"

scp $scriptDir/$bootstrap_ansible_script $scriptDir/$bootstrap_admin_script $sshPubKeyFilepath $sshHost:~

# Remotely launch ansible bootstrap script
$remoteExec -c "'~/$bootstrap_ansible_script'"

# Remotely launch admin bootstrap script
$remoteExec -c "'~/$bootstrap_admin_script $adminUsername ~/$( basename $sshPubKeyFilepath )'"

