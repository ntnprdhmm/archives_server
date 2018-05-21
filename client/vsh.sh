#!/bin/bash

usage(){ 
	echo "Usage: ./vsh.sh [OPTION] [PARAMETER...]"
	echo "" 
	echo "-h, --help			display help" 
	echo "-list [host] [port]		list all the archives on the server"
	echo ""
	echo "Report bugs to antoine.prudhomme@utt.fr"
}

unrecognized_option(){
	# $1 is the name of the optionunrecognized
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

# Handle options
if [[ $1 == "--help" || $1 == "-h" ]];
then 
	usage
elif [[ $1 == "-list" ]];
then
	# this option require 2 more parameters
	[[ $# -lt 3 ]] && option_error "vsh -list"
	
	# send the request and reopen netcat to  
	# see the server's response
	echo "list" > client_in.txt
	nc $2 $3 < client_in.txt
	sleep 1s
	nc $2 $3
else
	# the provided option is unknown
	unrecognized_option $1
fi