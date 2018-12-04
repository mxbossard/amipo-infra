#! /bin/sh -e

# Bootstrap an admin user on a debian system 
# Need sudo command. You may use bootstrap_ansible_debian.sh to install it.

# usage: command adminUsername sshPubKeyFilepath

adminUsername="$1"
sshPubKeyFilepath="$2"
scriptDir="$(dirname $(readlink -f $0))"

usage() {
	>&2 echo "usage: $0 adminUsername sshPubKeyFilepath"
	>&2 echo "\tadminUsername: user name of administrator to create"
	>&2 echo "\tsshPubKeyFilepath: admin ssh pub key file to deploy"
}

if [ -z "$adminUsername" ] || [ -z "$sshPubKeyFilepath" ]
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

# Check if user is sudoer
adminExec=""
if [ "$( whoami )" = "root" ]
then
        echo "Executing commands with root user"
        adminExec="/bin/sh -c"
elif sudo -v
then
        echo "Executing command with sudo"
        adminExec="sudo /bin/sh -c"
else
        echo "Escalating root privileges to execute commands"
        su -
        adminExec="/bin/sh -c"
fi

adminHome="/home/$adminUsername"
authorizedKeysFilepath="$adminHome/.ssh/authorized_keys"
remoteKeyFilename="$(basename $sshPubKeyFilepath)"

# Add admin user with disabled password login
echo "Creating or updating admin user..."
$adminExec "addgroup --system --quiet admin"
$adminExec "addgroup --system --quiet $adminUsername"
$adminExec "adduser --system --group --shell /bin/sh --home $adminHome --disabled-password --quiet $adminUsername"
$adminExec "usermod --lock --shell /bin/sh --home $adminHome --groups admin,$adminUsername $adminUsername"

# Configure sudo without password for admin group
echo "Configure sudoers"
$adminExec "echo '%admin ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/admin"
$adminExec "chmod 0440 /etc/sudoers.d/admin"


echo "Deploying admin ssh pub key..."
# Remotely create admin .ssh directory
$adminExec "test -d $adminHome/.ssh || mkdir $adminHome/.ssh"
$adminExec "cat ~/$remoteKeyFilename >> $authorizedKeysFilepath"
$adminExec "chown -R $adminUsername:$adminUsername $adminHome/.ssh; chmod 0600 -R $adminHome/.ssh/*"
#$adminExec "sort -u $authorizedKeysFilepath > $authorizedKeysFilepath"

$adminExec "rm -f -- ~/$remoteKeyFilename"
