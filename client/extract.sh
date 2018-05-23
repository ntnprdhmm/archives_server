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
	elif [[ $line =~ ^.+d.+ ]];
	then 
		# this line is a subdirectory of the current_dir
		echo "found subdir: $line"
	elif [[ $line =~ ^.+-.+ ]];
	then 
		# this line is a file of the current_dir
		echo "found file: $line"
	fi
done
