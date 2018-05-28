#!/bin/bash

archive_path="$VSH_ARCHIVES_PATH$1"

# if the archive doesn't exists, return an error code
# else return the content of the archive

if [ ! -f $archive_path ];
then
	echo "-1"
	exit 1
fi

cat $archive_path
