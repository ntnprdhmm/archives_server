#!/bin/bash

port=$1

# define server's shared variables
VSH_ARCHIVES_PATH="archives/"
export VSH_ARCHIVES_PATH

# if the backpipe doesn't exists, create it
if [ ! -e backpipe ];
then
	mkfifo backpipe
fi

while true;
do
	# listen while there is a request
	echo "server is listening"
	# intercept the request
	nc -lp $port > server_in.txt

	# read from file, and split (by space) parts in array
	cmd=$(<server_in.txt)
	cmd_parts=( $cmd )

	case ${cmd_parts[0]} in
		"list") 
			nc -l $port < backpipe | bash list.sh> backpipe;;
		"extract") 
			nc -l $port < backpipe | bash extract.sh ${cmd_parts[1]} > backpipe;;
		"browse")
			nc -l $port < backpipe | bash browse.sh ${cmd_parts[1]} > backpipe;;
		"browsels")
			nc -l $port < backpipe | bash browse_ls.sh ${cmd_parts[1]} ${cmd_parts[2]} > backpipe;;
		"browsecat")
			nc -l $port < backpipe | bash browse_cat.sh ${cmd_parts[1]} ${cmd_parts[2]} ${cmd_parts[3]} > backpipe;;
		"browserm")
			nc -l $port < backpipe | bash browse_rm.sh ${cmd_parts[1]} ${cmd_parts[2]} ${cmd_parts[3]} > backpipe;;
		"browsermdir")
			nc -l $port < backpipe | bash browse_rmdir.sh ${cmd_parts[1]} ${cmd_parts[2]} > backpipe;;
		"direxists")
			nc -l $port < backpipe | bash dir_exists.sh ${cmd_parts[1]} ${cmd_parts[2]} > backpipe;;
		*)
			echo "Unknow command. Try 'list', 'extract' or 'browse'";;
	esac
done