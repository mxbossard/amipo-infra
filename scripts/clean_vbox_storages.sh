#! /bin/sh

storagesList="$@"

echo $storagesList

for file in $storagesList
do
	echo "Checking $file ..."
	if [ ! -f "$file" ]
	then
		# File don't exists, try to remove the corresponding hdd
		echo "File $file don't exists."
		filename=$(basename $file)
		uuid=$(vboxmanage list hdds | grep -e "^UUID:" -e "^Location:" | grep -B1 "$filename" | head -1 | awk '{print $2}')
		if [ ! -z "$uuid" ]
		then
			echo "Removing HDD $uuid correspondig to file: $file ..."
			vboxmanage closemedium disk $uuid --delete
		fi

	fi
done
