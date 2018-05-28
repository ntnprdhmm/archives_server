#!/bin/bash

archive_name=$1
archive_path="server/archives/$archive_name"
directory=$2

# find the directory to remove
dir_line=$(grep -P -n -m 1 "^directory\s${directory}" $archive_path | sed 's/\([0-9]*\).*/\1/')
current_line=$dir_line
if [[ $directory ]];
then
	# go through each direct child
	bash server/browse_ls.sh $archive_name $directory > temp.txt
	while read line
	do
		((current_line++))
		if [[ $(echo $line | grep -P "^([^\s]+)(\s)d.+$") ]];
		then
			# if it's a directory
			sed -i "$(($current_line))s/.*//" $archive_path
		elif [[ $(echo $line | grep -P "^([^\s]+)(\s)-.+$") ]];
		then
			# if it's a file
			bash server/browse_rm.sh $archive_name "$directory/$(echo $line | cut -d " " -f 1)"
		elif [[ $line == "@" ]];
		then
			break
		fi
	done < temp.txt
	# clear the directory line
	sed -i "$(($dir_line))s/.*//" $archive_path
	
	# remove the directory from his parent
	parent=$(dirname $directory)
	parent_line=$(grep -P -n -m 1 "^directory\s${parent}" $archive_path | sed 's/\([0-9]*\).*/\1/')
	if [[ $parent_line ]];
	then
		# the deleted folder has a parent is the archive
		# let's find the index line of the removed dir in his parent's children
		bash server/browse_ls.sh $archive_name $parent > temp4.txt
		line_in_parent=$(grep -P -n -m 1 "^$(basename $directory)\sd" temp4.txt | sed 's/\([0-9]*\).*/\1/')
		if [[ $line_in_parent ]];
		then
			sed -i "$((parent_line+line_in_parent))s/.*//" $archive_path
		fi	
	fi
else
	echo "-1"
fi