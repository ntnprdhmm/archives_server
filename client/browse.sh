#!/bin/bash

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

show_preface(){
	echo "Welcome to the VSH browse shell."
	echo "You are browsing the archive '$archive_name'"
	echo ""
	echo "Type 'help' for help. Type 'exit' to leave the browse shell."
	echo ""
}

usage(){ 
	echo "-------"
	echo ""
	echo "Browse commands:"
	echo "" 
	echo "pwd			show the current directory" 
	echo "ls [DIR]		list the content of the specified directory"
	echo "cd <DIR>		move to the specified specified directory"
	echo "cat <FILE>		cat the content of the specified file"
	echo "rm <FILE>		remove the specified file"
	echo "rmdir <DIR>		remove the specified directory"
	echo ""
	echo "Each path (for a directory or a file) can be absolute or relative to the current directory."
	echo ""
	echo "-------"
}

send_request() {
	# send the request to the server and reopen netcat to  
	# save the server's response
	echo $1 > $VSH_CLIENT_REQ
	nc $host $port < $VSH_CLIENT_REQ
	sleep 1s
	nc $host $port > $VSH_CLIENT_RES
}

remove(){
	# remove the given file
	# $1 is the file in the archive to delete
	send_request "browserm $archive_name $1"
}

remove_dir(){
	# remove the given directory
	# $1 is the directory in the archive to delete 
	send_request "browsermdir $archive_name $1"
}

fetch_file(){
	# fetch the content of the given file
	# $1 is the directory in the archive where is located the file
	# $2 is the files's name
	send_request "browsecat $archive_name $1 $2"
}

fetch_directory(){
	# fetch the content of a directory
	# $1 is the directory to fetch
	send_request "browsels $archive_name $1"
}

directory_exists(){
	# check if the dir exists in the archive
	# $1 is the directory to check
	# return 0 (no) or 1 (yes)
	send_request "direxists $archive_name $1"
}

handle_ls(){
	# $1 is the directory to ls
	# find the target dir from current dir and the given relative path to the dir to ls 
	target_dir=$(bash client/navigate.sh $current_location $1)
	target_dir=${target_dir::-1}
	# fetch the content of the directory to ls
	fetch_directory "$archive_root$target_dir"
	# format and display the server's response
	str=""
	while read line 
	do 
		if [[ $(echo $line | grep -P "^[^\s]+\sd") ]];
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
	done < $VSH_CLIENT_RES
	echo $str
}

handle_cd(){
	# $1 should be the a path (where to go)
	if [[ $1 ]];
	then
		target_location=$(bash client/navigate.sh $current_location $1)
		target_location=${target_location::-1}

		# check if the resulting dir exists in the archive
		directory_exists "$archive_root$target_location"
		exists=$(cat $VSH_CLIENT_RES)
		if [[ $exists == "1" ]];
		then
			current_location="$target_location/"
		else
			echo "cd: invalid operand" >&2
			echo "cd: you must provide a valid the destination" >&2
		fi
	else
		echo "cd: missing operand" >&2
		echo "cd: you must provide the destination" >&2
	fi
}

handle_cat(){
	# $1 should be the path to the file to cat
	if [[ $1 ]];
	then
		target_file=$(bash client/navigate.sh $current_location $(dirname $1))
		target_file="$target_file$(basename $1)"
		
		fetch_file $(dirname "$archive_root$target_file") $(basename $target_file) 
		if [[ $(cat $VSH_CLIENT_RES) == "-1" ]];
		then
			echo "cat: invalid operand" >&2
			echo "cat: this file doesn't exist" >&2
		else
			cat $VSH_CLIENT_RES
		fi
	else
		echo "cat: missing operand" >&2
		echo "cat: you must provide the file to print" >&2
	fi
}

handle_rm(){
	# $1 should be the path to the file to remove
	if [[ $1 ]];
	then
		target_location=$(bash client/navigate.sh $current_location $1)
		target_location=${target_location::-1}

		remove "$archive_root$target_location" 
		if [[ $(cat $VSH_CLIENT_RES) == "-1" ]];
		then
			echo "rm: invalid operand" >&2
			echo "rm: this file doesn't exist" >&2
		fi
	else
		echo "rm: missing operand" >&2
		echo "rm: you must provide the file or directory to remove" >&2
	fi
}

handle_rmdir(){
	# $1 is the path of the directory to remove
	if [[ $1 ]];
	then
		target_location=$(bash client/navigate.sh $current_location $1)
		target_location=${target_location::-1}

		remove_dir "$archive_root$target_location"
		cat $VSH_CLIENT_RES
		if [[ $(cat $VSH_CLIENT_RES) == "-1" ]];
		then
			echo "rmdir: invalid operand" >&2
			echo "rmdir: this directory doesn't exist" >&2
		fi
	else
		echo "rmdir: missing operand" >&2
		echo "rmdir: you must provide the directory to remove" >&2
	fi
}

show_preface

cmd=""
while [[ $cmd != "exit" ]];
do
	# [0] => the command
	# [1] => parameter
	cmd_parts=( $cmd )
	if [[ ${cmd_parts[0]} == "pwd" ]];
	then
		echo $current_location
	elif [[ ${cmd_parts[0]} == "ls" ]];
	then
		handle_ls ${cmd_parts[1]}
	elif [[ ${cmd_parts[0]} == "cd" ]];
	then
		handle_cd ${cmd_parts[1]}
	elif [[ ${cmd_parts[0]} == "cat" ]];
	then
		handle_cat ${cmd_parts[1]}
	elif [[ ${cmd_parts[0]} == "rm" ]];
	then
		handle_rm ${cmd_parts[1]}
	elif [[ ${cmd_parts[0]} == "rmdir" ]];
	then
		handle_rmdir ${cmd_parts[1]}
	elif [[ ${cmd_parts[0]} == "help" ]];
	then
		usage
	else
		echo "vsh browse: command not found: ${cmd_parts[0]}"
	fi
	read -p "vsh@$host:$port {$archive_name} $current_location :> " cmd
done