#! /bin/sh

PACKAGES_TO_INSTALL="python3.5 sudo"

adminExec=""
if [ "$( whoami )" = "root" ]
then
	echo "Executing commands with root user"
	adminExec="/bin/sh -c"
elif sudo -v 2> /dev/null
then
	echo "Executing command with sudo"
	adminExec="sudo /bin/sh -c"
else
	echo "Current user is not a sudoer. Escalating root privileges to reexecute the script"
	su - root -c "$0" $@
	exit 0
fi

echo "Installing packages ..."
$adminExec "apt-get update"
$adminExec "apt-get install -y $PACKAGES_TO_INSTALL"

echo "Adding python3 in PATH"
test -f /usr/bin/python && $adminExec "rm /usr/bin/python"
$adminExec "ln -s /usr/bin/python3.5 /usr/bin/python"

