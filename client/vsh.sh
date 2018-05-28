#!/bin/bash

# there are always host and port as parameter
# for extract and browse, $4 will be the archive name
host=$2
port=$3

usage(){ 
	echo "Usage: ./vsh.sh [OPTION] [PARAMETER...]"
	echo "" 
	echo "-h, --help					display help" 
	echo "-list [host] [port]				list all the archives on the server"
	echo "-extract [host] [port] [archive name]		extract the archive"
	echo "-browse [host] [port] [archive name]		open a shell to explore the archive"
	echo ""
	echo "Report bugs to antoine.prudhomme@utt.fr or mathilde.sandor@utt.fr"
}

unrecognized_option(){
	# $1 is the name of the option unrecognized
	echo "vsh: unrecognized option '$1'" >&2
	echo "Try 'vsh --help' for more information" >&2
}

option_error(){
	# $1 is the name of this option (-list for example)
	echo "$1: missing operand" >&2
	echo "Try 'vsh --help' for more information." >&2
	exit 1
}

# No option provided 
[[ $# -lt 1 ]] && option_error "vsh"

send_request(){
	# send the request and reopen netcat to  
	# receive the server's response
	# this response is displayed in the console
	# $1 is the request to send
	echo $1 > client_in.txt
	nc $host $port < client_in.txt
	sleep 1s
	nc $host $port
}

# Handle options
if [[ $1 == "--help" || $1 == "-h" ]];
then 
	usage
elif [[ $1 == "-list" ]];
then
	# this option requires 2 more parameters
	[[ $# -lt 3 ]] && option_error "vsh -list"
	send_request "list"
elif [[ $1 == "-extract" ]];
then
	# this option requires 3 more parameters
	[[ $# -lt 4 ]] && option_error "vsh -extract"
	send_request "extract $4" > /dev/null
	bash client/extract.sh
elif [[ $1 == "-browse" ]];
then
	# this option requires 3 more parameters
	[[ $# -lt 4 ]] && option_error "vsh -browse"
	# here, we capture the response to use it in another script
	root=$(send_request "browse $4")
	bash client/browse.sh $2 $3 $4 $root
else
	# the provided option is unknown
	unrecognized_option $1
fi