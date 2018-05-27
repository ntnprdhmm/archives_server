archive_name=$1
archive_path="server/archives/$archive_name"
directory=$(dirname $2)
file_name=$(basename $2)

# list all files/directories in the given directory
bash server/browse_ls.sh $archive_name $directory > temp.txt

# search the line that describes the file in the archive, 
# and the index of this line
file_line=1
file_desc=""
while read line
do
	if [[ $(echo $line | grep -P "^${file_name}\s-") ]];
	then
		# line found
		file_desc=$line
		break
	else
		((file_line++))
	fi
done < temp.txt

# continue only if we found the find (else, there is nothing to remove cause
# it didn't exists)
if [[ $file_desc == "" ]];
then
	echo "-1"
else
	# if the file as 2 complementary informations => it has content
	# so remove this content
	parts=( $file_desc )
	if [[ ${#parts[@]} -eq 5 ]];
	then
		body_start=$(cat $archive_path | head -1 | cut -d ":" -f 2)
		content_start=${parts[3]}
		content_size=${parts[4]}
		for i in $(seq 0 $(($content_size-1)))
		do
			# clean each line by line number
			sed -i "$(($i+$body_start+$content_start-1))s/.*//" $archive_path
		done
	fi
	# remove the line that describes the file in the archive
	dir_line=$(grep -P -n -m 1 "^directory\s${directory}" $archive_path | sed 's/\([0-9]*\).*/\1/')
	sed -i "$(($dir_line+$file_line))s/.*//" $archive_path
fi