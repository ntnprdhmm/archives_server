# name parameters
host=$1
port=$2
archive_name=$3
archive_root=$4

# if the server responded with an error code, display message and leave here 
if [[ $archive_root == "-1" ]];
then
	echo "can't find the requested archive on the server"
	exit 1
fi

current_location="/"

remove(){
	# send the request and reopen netcat to  
	# see the server's response
	# $1 is the file in the archive to delete
	echo "browserm $archive_name $1" > client_in.txt
	nc $host $port < client_in.txt
	sleep 1s
	nc $host $port > client_out.txt
}

remove_dir(){
	# send the request and reopen netcat to  
	# see the server's response
	# $1 is the directory in the archive to delete 
	echo "browsermdir $archive_name $1" > client_in.txt
	nc $host $port < client_in.txt
	sleep 1s
	nc $host $port > client_out.txt
}

fetch_file(){
	# send the request and reopen netcat to  
	# see the server's response
	# $1 is the directory in the archive where is located the file
	# $2 is the files's name
	echo "browsecat $archive_name $1 $2" > client_in.txt
	nc $host $port < client_in.txt
	sleep 1s
	nc $host $port > client_out.txt
}

fetch_location(){
	# send the request and reopen netcat to  
	# see the server's response
	echo "browsels $archive_name $1" > client_in.txt
	nc $host $port < client_in.txt
	sleep 1s
	nc $host $port > client_out.txt
}

directory_exists(){
	# check if the dir exists in the archive
	# return 0 (no) or 1 (yes)
	echo "direxists $archive_name $1" > client_in.txt
	nc $host $port < client_in.txt
	sleep 1s
	nc $host $port > client_out.txt
}

cmd=""
while [[ $cmd != "exit" ]];
do
	cmd_parts=( $cmd )
	if [[ ${cmd_parts[0]} == "pwd" ]];
	then
		echo $current_location
	elif [[ ${cmd_parts[0]} =~ "ls" ]];
	then
		target_location=$(bash client/navigate.sh $current_location ${cmd_parts[1]})
		target_location=${target_location::-1}
		
		fetch_location "$archive_root$target_location"
		# format and display the response
		str=""
		while read line 
		do 
			if [[ $line =~ ^.+d.+ ]];
			then
				# it's a dir
				str+="$(echo $line | cut -d " " -f 1)/ "
			else
				# it's a file
				str+="$(echo $line | cut -d " " -f 1)"
				# check if executable
				if [[ $line =~ .*[r\-][w\-][x].* ]];
				then
					str+="*"
				fi
				str+=" "
			fi
		done < client_out.txt
		echo $str
	elif [[ ${cmd_parts[0]} =~ "cd" ]];
	then
		# check that there is a second parameter (where to go)
		if [[ ${#cmd_parts[@]} -lt 2 ]];
		then
			echo "cd: missing operand" >&2
			echo "cd: you must provide the destination" >&2
		else
			if [[ ${cmd_parts[1]} == "/" ]];
			then
				current_location="/"
			elif [[ ${cmd_parts[1]} == ".." ]]
			then
				current_location=$(dirname $current_location)
			else
				target_location=$(bash client/navigate.sh $current_location ${cmd_parts[1]})
				target_location=${target_location::-1}
				# check if the resulting dir exists in the archive
				directory_exists "$archive_root$target_location"
				exists=$(cat client_out.txt)
				if [[ $exists == "1" ]];
				then
					current_location="$target_location/"
				else
					echo "cd: invalid operand" >&2
					echo "cd: you must provide a valid the destination" >&2
				fi
			fi			
		fi
	elif [[ ${cmd_parts[0]} == "cat" ]];
	then
		# check that there is a seconde parameter (the file to print)
		if [[ ${#cmd_parts[@]} -lt 2 ]];
		then
			echo "cat: missing operand" >&2
			echo "cat: you must provide the file to print" >&2
		else
			fetch_file "$archive_root$current_location" ${cmd_parts[1]} 
			if [[ $(cat client_out.txt) == "-1" ]];
			then
				echo "cat: invalid operand" >&2
				echo "cat: this file doesn't exist" >&2
			else
				cat client_out.txt
			fi
		fi
	elif [[ ${cmd_parts[0]} == "rm" ]];
	then
		# check that there is a second parameter (the file or directory to remove)
		if [[ ${#cmd_parts[@]} -lt 2 ]];
		then
			echo "rm: missing operand" >&2
			echo "rm: you must provide the file or directory to remove" >&2
		else
			target_location=$(bash client/navigate.sh $current_location ${cmd_parts[1]})
			target_location=${target_location::-1}

			remove "$archive_root$target_location" 
			cat client_out.txt
			if [[ $(cat client_out.txt) == "-1" ]];
			then
				echo "rm: invalid operand" >&2
				echo "rm: this file doesn't exist" >&2
			fi
		fi
	elif [[ ${cmd_parts[0]} == "rmdir" ]];
	then
		# check that there is a second parameter (the file or directory to remove)
		if [[ ${#cmd_parts[@]} -lt 2 ]];
		then
			echo "rm: missing operand" >&2
			echo "rm: you must provide the directory to remove" >&2
		else
			target_location=$(bash client/navigate.sh $current_location ${cmd_parts[1]})
			target_location=${target_location::-1}

			remove_dir "$archive_root$target_location" 
			if [[ $(cat client_out.txt) == "-1" ]];
			then
				echo "rmdir: invalid operand" >&2
				echo "rmdir: this directory doesn't exist" >&2
			fi
		fi
	fi
	read -p "vsh@$host:$port {$archive_name} $current_location :> " cmd
done