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

remoteExec="ssh -o UserKnownHostsFile=/dev/null -tt $sshHost /bin/sh"

boostrapAnsibleScript="bootstrap_ansible_debian.sh"
boostrapAdminScript="bootstrap_admin_user_debian.sh"
sshPubKeyFilename="$( basename $sshPubKeyFilepath )"

scp -o UserKnownHostsFile=/dev/null $scriptDir/$boostrapAnsibleScript $scriptDir/$boostrapAdminScript $sshPubKeyFilepath $sshHost:/tmp

echo "Warning ! Commands are executed on remote machine. You may be prompted for remote root password."

# Aggregate remote command to minize ssh session count.

# Remotely launch ansible bootstrap script\
remoteCmd="/tmp/$boostrapAnsibleScript"
# Remotely launch admin bootstrap script\
remoteCmd="$remoteCmd; /tmp/$boostrapAdminScript $adminUsername /tmp/$sshPubKeyFilename"
# Clean
remoteCmd="$remoteCmd; rm -f -- /tmp/$boostrapAnsibleScript /tmp/$boostrapAdminScript /tmp/$sshPubKeyFilename"

$remoteExec -c "$remoteCmd"
