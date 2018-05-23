# read the first line of the file extracted
first_line=$(cat extracted | head -1)

# if the server responded with an error code, display message and leave here 
if [[ $first_line == "-1" ]];
then
	echo "can't find the requested archive on the server"
	exit 1
fi

# the server responded with the archive content, let's extract it
# start by parsing the first line
header_start=$(echo $first_line | cut -d ":" -f 1)
body_start=$(echo $first_line | cut -d ":" -f 2) 


# parse the string of permission (drwxrwxrwx)
# and return permissions in number format (777)
calculate_permissions(){
	p=$1
	user=0
	group=0
	owner=0
	[[ ${p:1:1} != "-" ]] && user=$(($user+4))
	[[ ${p:2:1} != "-" ]] && user=$(($user+2))
	[[ ${p:3:1} != "-" ]] && user=$(($user+1))
	[[ ${p:4:1} != "-" ]] && group=$(($group+4))
	[[ ${p:5:1} != "-" ]] && group=$(($group+2))
	[[ ${p:6:1} != "-" ]] && group=$(($group+1))
	[[ ${p:7:1} != "-" ]] && owner=$(($owner+4))
	[[ ${p:8:1} != "-" ]] && owner=$(($owner+2))
	[[ ${p:9:1} != "-" ]] && owner=$(($owner+1))
	echo "$user$group$owner"
}

current_dir=""

# read each line of the file's header
cat extracted | head $(($body_start * -1 + 1)) | tail $(($(($body_start - $header_start)) * -1)) | while read line;
do
	# handle lines
	if [[ $line =~ ^directory ]];
	then
		# update the current_dir path
		current_dir=$(echo $line | cut -d " " -f 2)
		# create this dir if it doesn't exists
		if [ ! -d $current_dir ];
		then
			mkdir -p $current_dir
			echo "new directory created: $current_dir"
		fi
	elif [[ $line =~ ^.+d.+ ]]; # match a directory
	then
		# create the directory
		sub_dir=$(echo $line | cut -d " " -f 1)
		sub_dir_path="$current_dir/$sub_dir"
		mkdir -p $sub_dir_path # -p to not display error if the dir already exists
		# set the permissions
		permissions=$(calculate_permissions $(echo $line | cut -d " " -f 2))
		chmod $permissions $sub_dir_path
		echo "new subdirectory created: $sub_dir_path"
	elif [[ $line =~ ^.+-.+ ]]; # match a file
	then 
		# create the file
		file=$(echo $line | cut -d " " -f 1)
		file_path="$current_dir/$file"
		touch $file_path
		# set the permissions
		permissions=$(calculate_permissions $(echo $line | cut -d " " -f 2))
		chmod $permissions $file_path
		echo "new file created: $file_path"
	fi
done
