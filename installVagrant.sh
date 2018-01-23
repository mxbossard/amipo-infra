#! /bin/sh 

# Setup script for Vagrant + virtualbox. Tested on deb systems not rpm ones. 	

# Config
VAGRANT_REPO_URL="https://releases.hashicorp.com/vagrant"
VAGRANT_VERSION="2.0.1"


vagrantPackageType="$1" # ether dep or rpm
vagrantBaseUrl="$VAGRANT_REPO_URL/$VAGRANT_VERSION"
vagrantSignature="vagrant_${VAGRANT_VERSION}_SHA256SUMS.sig"
vagrantChecksum="vagrant_${VAGRANT_VERSION}_SHA256SUMS"
vagrantBinary="vagrant_${VAGRANT_VERSION}_x86_64.$vagrantPackageType"

usage() {
	echo "usage: $0 package"
	echo "where package is ether deb or rpm"
	exit 1
}

if [ "$vagrantPackageType" != "deb" ] && [ "$vagrantPackageType" != "rpm" ]
then
	usage
fi

tmpDir="$(mktemp -d /tmp/vagrant.XXXXXXXXXX)"
cd $tmpDir
for file in $vagrantSignature $vagrantChecksum $vagrantBinary
do
	echo "Downloading of $vagrantBaseUrl/$file ..."
	curl -OS "$vagrantBaseUrl/$file"
done

if [ "$vagrantPackageType" = "deb" ]
then
	sudo apt install gpgv
elif [ "$vagrantPackageType" = "rpm" ]
then
	# FIXME is it the good package name ?
	sudo yum install gpgv
fi

echo "Verifying Vagrant checksum..."

# Import hashicorp gpg public key
gpg --import hashicorp.asc

# Verify the signature file is untampered.
gpg --verify $vagrantSignature $vagrantChecksum

# Verify the SHASUM matches the binary.
grep "$vagrantBinary" $vagrantChecksum | shasum -a 256 -c

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

rm -- $tmpDir/$vagrantSignature $tmpDir/$vagrantChecksum $tmpDir/$vagrantBinary
rmdir -- $tmpDir

