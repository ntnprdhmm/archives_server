#!/bin/bash

archive_name=$1
archive_path="$VSH_ARCHIVES_PATH$archive_name"
directory=$2

# remove each directory matching the given directory 
# (== the directory concerned + his children)

grep -P "^directory\s$directory(\/.+)?$" $archive_path > temp3.txt

while read subdir_desc
do
	subdir=$(echo $subdir_desc | cut -d " " -f 2)
	bash server/remove_dir.sh $archive_name $subdir
done < temp3.txt