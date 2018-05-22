#!/bin/bash

# if the backpipe doesn't exists, create it
if [ ! -e server/backpipe ];
then
	mkfifo server/backpipe
fi

while true;
do
	# listen while there is a request
	echo "server is listening"
	# intercept the request
	nc -lp $1 > server_in.txt

	# read from file, and split (by space) parts in array
	cmd=$(<server_in.txt)
	cmd_parts=( $cmd )

	# do something depending on the request
	if [[ ${cmd_parts[0]} == "list" ]]; 
	then
  		nc -l 1234 < server/backpipe | bash server/list.sh> server/backpipe
	elif [[ ${cmd_parts[0]} == "extract" ]];
	then
		nc -l 1234 < server/backpipe | bash server/extract.sh ${cmd_parts[1]} > server/backpipe
	else
		echo "Unknow command. Try 'list', 'extract"
	fi
done