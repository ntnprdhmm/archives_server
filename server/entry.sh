#!/bin/bash
while read cmd
do
	if [[ $cmd == "list" ]]; 
	then
  		echo "list ok"
	elif [[ $cmd == "browse" ]]; 
	then
		echo "browse ok"
	elif [[ $cmd == "extract" ]];
	then
		echo "extract ok"
	else
		echo "Unknow command. Try 'list', 'browse' or 'extract'"
	fi
done
