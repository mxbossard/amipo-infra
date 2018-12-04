#! /bin/sh

hostnames="$@"

for hostname in $hostnames
do
	echo "Waiting a ping response from $hostname ..."
	while ! ping -c1 $hostname
	do
		sleep 1
	done
done

