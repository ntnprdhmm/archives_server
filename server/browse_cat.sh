archives_path="server/archives/"

archive_name=$1
directory=$2
file_to_print=$3

# reuse code of browse_ls to display the content of the directory
bash server/browse_ls.sh $archive_name $directory > temp2.txt

found=false

# now, search the 
while read line 
do 
	match=$(echo $line | grep -P "^${file_to_print}\s-")
	if [[ $match ]];
	then
		# we found the file
		# get the lines of the file's content
		found=true
		parts=($(echo $match))
		
		# extract and cat the content
		body_start=$(cat $archives_path$archive_name | head -1 | cut -d ":" -f 2) 
		archive_length=$(wc -l $archives_path$archive_name | cut -d " " -f 1)
		content_start=$(($body_start - $archive_length + ${parts[3]} - 3))
		content_size=$((${parts[4]} * -1))
		cat $archives_path$archive_name | tail $content_start | head $content_size

		break
	fi 
done < temp2.txt

# if the file has not been found, return an error code
if [[ $found == false ]];
then
	echo "-1"
fi