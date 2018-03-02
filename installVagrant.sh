#! /bin/sh -e

# Setup script for Vagrant + virtualbox. Tested on deb systems not rpm ones. 	

# Config
VAGRANT_REPO_URL="https://releases.hashicorp.com/vagrant"
VAGRANT_VERSION="2.0.2"
VAGRANT_PLUGINS="landrush vagrant-persistent-storage"

vagrantPackageType="$1" # ether dep or rpm
vagrantBaseUrl="$VAGRANT_REPO_URL/$VAGRANT_VERSION"
vagrantSignature="vagrant_${VAGRANT_VERSION}_SHA256SUMS.sig"
vagrantChecksum="vagrant_${VAGRANT_VERSION}_SHA256SUMS"
vagrantBinary="vagrant_${VAGRANT_VERSION}_x86_64.$vagrantPackageType"

projectDir="$(dirname $(readlink -f $0))"
localDir="$projectDir/.amipoLocal"

usage() {
	echo "usage: $0 package"
	echo "where package is ether deb or rpm"
	exit 1
}

if [ "$vagrantPackageType" != "deb" ] && [ "$vagrantPackageType" != "rpm" ]
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

install_vagrant() {
	# Check vagrant version installed
	if [ "$(vagrant -v || echo 'Nope')" = "Vagrant $VAGRANT_VERSION" ]
	then
		echo "Vagrant $VAGRANT_VERSION already installed."
		return
	else
		echo "Installing Vagrant..."
	fi

	tmpDir="$(mktemp -d /tmp/vagrant.XXXXXXXXXX)"
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

	vagrant plugin repair || yes | vagrant plugin expunge --reinstall

	cd
	rm -- $tmpDir/$vagrantSignature $tmpDir/$vagrantChecksum $tmpDir/$vagrantBinary
	rmdir -- $tmpDir
}

install_required_packages() {
	echo "Installing Vagrant and VirtualBox..."
	if [ "$vagrantPackageType" = "deb" ]
	then
		sudo dpkg -i $vagrantBinary
		sudo apt install -y virtualbox-dkms virtualbox
	elif [ "$vagrantPackageType" = "rpm" ]
	then
		sudo rmp -ivh $vagrantBinary
		# FIXME are they the good packages names ?
		sudo yum install -y virtualbox-dkms virtualbox
	fi
}

install_vagrant_plugins() {
	pluginList=$(vagrant plugin list)
	for pluginName in $VAGRANT_PLUGINS
	do
		echo "$pluginList" | grep -e "^$pluginName " || vagrant plugin install $pluginName
	done

	vagrant plugin update
}

configure_dnsmasq() {
	dnsmasq -v || echo "Installing dnsmasq..." && install_packages dnsmasq 

	# Will not work everywhere !
	dnsConfFile="/etc/dnsmasq.d/vagrant-landrush"
	test -f $dnsConfFile || sudo /bin/sh -c "echo 'server=/dev/127.0.0.1#10053' > $dnsConfFile" && sudo service dnsmasq restart
}

build_local_env() {
	test -d $localDir || mkdir $localDir
	test -f $localDir/provisioning_key || ssh-keygen -f $localDir/provisioning_key -t rsa -b 4096 -q -N ''

}


# Display disclaimer
disclaimer

# Install required packages
install_packages curl gpgv virtualbox

# Try to install vagrant
install_vagrant

# Try to install vagrant plugins
install_vagrant_plugins

# Install and configure dnsmasq
configure_dnsmasq

# Build local env
build_local_env

