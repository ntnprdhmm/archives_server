#!/bin/bash

archive_name=$1
archive_path="$VSH_ARCHIVES_PATH$1"
directory=$2
file_to_print=$3

# reuse code of browse_ls to display the content of the directory
bash browse_ls.sh $archive_name $directory > temp2.txt

found=false

# now, search the requested file
while read line
do 
	match=$(echo $line | grep -P "^${file_to_print}\s-")
	if [[ $match ]];
	then
		# we found the file
		# get the lines of the file's content
		found=true
		parts=( $match )
		
		# extract and cat the content
		body_start=$(cat $archive_path | head -1 | cut -d ":" -f 2) 
		archive_length=$(wc -l $archive_path | cut -d " " -f 1)
		content_start=$(($body_start - $archive_length + ${parts[3]} - 3))
		content_size=${parts[4]}
		cat $archive_path | tail $content_start | head "-$content_size"

		break
	fi 
done < temp2.txt

# if the file has not been found, return an error code
if [[ $found == false ]];
then
	echo "-1"
fi