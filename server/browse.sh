#!/bin/bash

archive_path="$VSH_ARCHIVES_PATH$1"

# if the file doesn't exists, return an error code
# else, extract the archive's root directory and return it

if [ ! -f $archive_path ];
then
	echo "-1"
	exit 1
fi

root=$(cat $archive_path | grep -m 1 "^directory\s" | cut -d " " -f 2)

echo $root
