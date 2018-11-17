#! /bin/sh -e

# Setup script for Vagrant + virtualbox. Tested on deb systems not rpm ones. 	

# Config
VAGRANT_REPO_URL="https://releases.hashicorp.com/vagrant"
#VAGRANT_VERSION="2.1.5"
VAGRANT_VERSION="2.2.1"
VAGRANT_PLUGINS="landrush vagrant-persistent-storage vagrant-hostsupdater vagrant-vbguest"

VAGRANT_SSH_KEY_NAME="vagrant_ssh_key"

VIRTUALBOX_REPO_URL="https://download.virtualbox.org/virtualbox"
#VIRTUALBOX_VERSION="5.1.38"
VIRTUALBOX_VERSION="5.2.22"
VIRTUALBOX_DISTRIB="Ubuntu~trusty_amd64"

vagrantPackageType="$1" # ether dep or rpm
vagrantBaseUrl="$VAGRANT_REPO_URL/$VAGRANT_VERSION"
vagrantSignature="vagrant_${VAGRANT_VERSION}_SHA256SUMS.sig"
vagrantChecksum="vagrant_${VAGRANT_VERSION}_SHA256SUMS"
vagrantBinary="vagrant_${VAGRANT_VERSION}_x86_64.$vagrantPackageType"

virtualboxPackageType="$1" # ether dep or rpm
virtualboxBaseUrl="$VIRTUALBOX_REPO_URL/$VIRTUALBOX_VERSION"
virtualboxChecksum="SHA256SUMS"

projectDir="$(dirname $(readlink -f $0))"
localDir="$projectDir/.amipoLocal"

usage() {
	echo "usage: $0 PackageType"
	echo "where must be deb for now"
	exit 1
}

if [ "$vagrantPackageType" != "deb" ] #&& [ "$vagrantPackageType" != "rpm" ]
then
	usage
fi

disclaimer() {
	echo "This script is a helper to install vagrant on your computer. It requires some other programs and will try to install them. YOU NEED MULTIVERSE REPOSITORIES for this install to works. Plus this script is an alpha and may not work on your linux distribution, help us to improve it."
    	read -p "Do you wish to continue and try to install required programs ? [y/N] " yn
    	case $yn in
		[Yy]* ) break;;
		* ) exit;;
	esac
}

# Generate personal ssh keys for vagrant VMs
#yes | ssh-keygen -b 4096 -t rsa -f ansible/.ssh/vagrant_ssh_key -q -N ""

install_packages() {
	pkgs="$@"

	if [ "$vagrantPackageType" = "deb" ]
	then
		# debian system
		sudo apt update -y
		sudo apt upgrade -y
		sudo apt install -y $pkgs
	elif [ "$vagrantPackageType" = "rpm" ]
	then
		# redhat system
		# FIXME are they the good packages names ?
		sudo yum update -y
		sudo yum upgrade -y
		sudo yum install -y $pkgs
	fi
}

download_file() {
	sourceUrl="$1"
	destDir="$2"

	sourceFile="$( basename $sourceUrl )"

	cd "$destDir"
	echo "Downloading of $sourceUrl to $( pwd ) ..."
        test -f $destPath/$sourceFile || curl -OS "$sourceUrl"
        chmod a+r $destDir/$sourceFile
}

install_virtualbox() {
	# Check virtualbox version installed
	if [ "$(vagrant -v || echo 'Nope')" = "VirtualBox $VIRTUALBOX_VERSION" ]
	then
		echo "VirtualBox $VIRTUALBOX_VERSION already installed."
		return
	else
		echo "Installing VirtualBox $VIRTUALBOX_BINARY ..."
	fi

	tmpDir="/tmp/amipo_dl_virtualbox_$VIRTUALBOX_VERSION"
        test -d $tmpDir || mkdir $tmpDir
#	cd $tmpDir
#	for file in $virtualboxChecksum $VIRTUALBOX_BINARY
#	do
#		echo "Downloading of $virtualboxBaseUrl/$file ..."
#		test -f $file || curl -OS "$virtualboxBaseUrl/$file"
#		chmod a+r $file
#	done

	download_file "$virtualboxBaseUrl/$virtualboxChecksum" "$tmpDir"

	# Determine virtualbox binary file from checksum file against the distribution needed
	virtualboxBinary="$( cat $tmpDir/$virtualboxChecksum | grep $VIRTUALBOX_DISTRIB | awk '{print $2}' | cut -c2- )"

	download_file "$virtualboxBaseUrl/$virtualboxBinary" "$tmpDir"

	echo "Verifying VirtualBox checksum..."

	# Verify the SHASUM matches the binary.
	grep "$virtualboxBinary" $virtualboxChecksum | shasum -a 256 -c

	if [ "$vagrantPackageType" = "deb" ]
	then
		sudo dpkg -i $virtualboxBinary
	elif [ "$vagrantPackageType" = "rpm" ]
	then
		sudo rpm -ivh $tmpDir/$virtualboxBinary
	fi

	#rm -rf -- $tmpDir
}

install_vagrant() {
	# Check vagrant version installed
	if [ "$(vagrant -v || echo 'Nope')" = "Vagrant $VAGRANT_VERSION" ]
	then
		echo "Vagrant $VAGRANT_VERSION already installed."
		return
	else
		echo "Installing Vagrant v$VAGRANT_VERSION ..."
	fi

	tmpDir="/tmp/amipo_dl_vagrant_$VAGRANT_VERSION"
        test -d $tmpDir || mkdir $tmpDir
	cd $tmpDir
	for file in $vagrantSignature $vagrantChecksum $vagrantBinary
	do
		echo "Downloading of $vagrantBaseUrl/$file ..."
		test -f $file || curl -OS "$vagrantBaseUrl/$file"
		chmod a+r $file
	done

	echo "Verifying Vagrant checksum..."

	# Import hashicorp gpg public key
	gpg --import $projectDir/hashicorp.asc

	# Verify the signature file is untampered.
	gpg --verify $vagrantSignature $vagrantChecksum

	# Verify the SHASUM matches the binary.
	grep "$vagrantBinary" $vagrantChecksum | shasum -a 256 -c

	if [ "$vagrantPackageType" = "deb" ]
	then
		sudo dpkg -i $vagrantBinary
	elif [ "$vagrantPackageType" = "rpm" ]
	then
		sudo rpm -ivh $tmpDir/$vagrantBinary
	fi

	cd
	rm -- $tmpDir/$vagrantSignature $tmpDir/$vagrantChecksum $tmpDir/$vagrantBinary
	rmdir -- $tmpDir
}

install_required_packages() {
	echo "Installing Vagrant and VirtualBox..."
	if [ "$vagrantPackageType" = "deb" ]
	then
		sudo dpkg -i $vagrantBinary
		sudo apt install -y virtualbox-dkms virtualbox-5.2
	elif [ "$vagrantPackageType" = "rpm" ]
	then
		sudo rmp -ivh $vagrantBinary
		# FIXME are they the good packages names ?
		sudo yum install -y virtualbox-dkms virtualbox
	fi
}

install_vagrant_plugins() {
	echo "Updating or Repairing Vagrant plugins..."
	vagrant plugin update || output=$( vagrant plugin repair 2>&1 )
	echo $output | grep -i "failed" > /dev/null || echo $output
	echo $output | grep -i "failed" > /dev/null && yes | vagrant plugin expunge --reinstall

	pluginList=$( vagrant plugin list )
	for pluginName in $VAGRANT_PLUGINS
	do
		echo "$pluginList" | grep -e "^$pluginName " || vagrant plugin install $pluginName
	done
}

configure_dnsmasq() {
	dnsmasq -v || ( echo "Installing dnsmasq..." && install_packages dnsmasq )

	# Will not work everywhere !
	dnsConfFile="/etc/dnsmasq.d/vagrant-landrush"
	test -f $dnsConfFile || ( sudo /bin/sh -c "echo 'server=/dev/127.0.0.1#10053' > $dnsConfFile" && sudo service dnsmasq restart )
}

build_local_env() {
	test -d $localDir || mkdir $localDir
	test -f $localDir/$VAGRANT_SSH_KEY_NAME || ( echo "We will generate a provisioning key." ; ssh-keygen -f $localDir/$VAGRANT_SSH_KEY_NAME -t rsa -b 4096 -q -N '' )

}


# Display disclaimer
disclaimer

# Install required packages
install_packages curl gpgv #virtualbox-dkms virtualbox virtualbox-qt

# Try to install virtualbox
install_virtualbox

# Try to install vagrant
install_vagrant

# Try to install vagrant plugins
install_vagrant_plugins

# Install and configure dnsmasq
#configure_dnsmasq

# Build local env
build_local_env

