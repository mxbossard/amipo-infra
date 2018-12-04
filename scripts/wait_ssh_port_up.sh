#! /bin/sh
echo "Waiting network of $1 to be up ..."

#while ! ping -c1 "$1" 2> /dev/null > /dev/null
while ! telnet "$1" 22 2> /dev/null > /dev/null
do
	sleep 1
	echo -n "."
done

echo "$1 network is up"
