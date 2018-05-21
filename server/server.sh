#!/bin/bash

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
	nc -lp $1 > server_in.txt

	cmd=$(<server_in.txt)

	# do something depending on the request
	if [[ $cmd == "list" ]]; 
	then
  		nc -l 1234 < server/backpipe | echo "list ok server" > server/backpipe
	else
		echo "Unknow command. Try 'list'"
	fi
done