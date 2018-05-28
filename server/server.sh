#!/bin/bash

port=$1

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
	nc -lp $port > server_in.txt

	# read from file, and split (by space) parts in array
	cmd=$(<server_in.txt)
	cmd_parts=( $cmd )

	case ${cmd_parts[0]} in
		"list") 
			nc -l $port < server/backpipe | bash server/list.sh> server/backpipe;;
		"extract") 
			nc -l $port < server/backpipe | bash server/extract.sh ${cmd_parts[1]} > server/backpipe;;
		"browse")
			nc -l $port < server/backpipe | bash server/browse.sh ${cmd_parts[1]} > server/backpipe;;
		"browsels")
			nc -l $port < server/backpipe | bash server/browse_ls.sh ${cmd_parts[1]} ${cmd_parts[2]} > server/backpipe;;
		"browsecat")
			nc -l $port < server/backpipe | bash server/browse_cat.sh ${cmd_parts[1]} ${cmd_parts[2]} ${cmd_parts[3]} > server/backpipe;;
		"browserm")
			nc -l $port < server/backpipe | bash server/browse_rm.sh ${cmd_parts[1]} ${cmd_parts[2]} ${cmd_parts[3]} > server/backpipe;;
		"browsermdir")
			nc -l $port < server/backpipe | bash server/browse_rmdir.sh ${cmd_parts[1]} ${cmd_parts[2]} > server/backpipe;;
		"direxists")
			nc -l $port < server/backpipe | bash server/dir_exists.sh ${cmd_parts[1]} ${cmd_parts[2]} > server/backpipe;;
		*)
			echo "Unknow command. Try 'list', 'extract' or 'browse'";;
	esac
done