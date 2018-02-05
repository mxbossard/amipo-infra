#! /bin/sh

echo "Installing python 2.7 ..."
sudo apt install -y python2.7
test -f /usr/bin/python || sudo ln -s /usr/bin/python2.7 /usr/bin/python

