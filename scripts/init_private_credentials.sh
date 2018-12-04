#! /bin/sh -e

# Initialise .privateCredentials workspace directory
VAGRANT_INSECURE_KEY_FILEPATH="$HOME/.vagrant.d/insecure_private_key"

scriptDir="$(dirname $(readlink -f $0))"
privCredDir="$scriptDir/../.privateCredentials"

test -d $privCredDir || mkdir $privCredDir
test -f $VAGRANT_INSECURE_KEY_FILEPATH || ( >&2 echo "Erreur: vagrant insecure private key not found at $VAGRANT_INSECURE_KEY_FILEPATH"; exit 1 )

cp $VAGRANT_INSECURE_KEY_FILEPATH $privCredDir/vagrant_insecure_private_key

