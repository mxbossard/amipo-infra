#! /bin/sh

# put the script dir in PATH
scriptDir=$(dirname $(readlink -f $0))

echo "export ANSIBLE_PATH=$scriptDir"
echo 'export PATH=$ANSIBLE_PATH:$PATH'
