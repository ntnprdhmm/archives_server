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

current_location='/'

cmd=""
while [[ $cmd != "exit" ]];
do
	if [[ $cmd == "pwd" ]];
	then
		echo $current_location
	fi

	read -p "vsh@$host:$port {$archive_name} $current_location :> " cmd
done