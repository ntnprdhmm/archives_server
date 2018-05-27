archive_path="server/archives/$1"
directory=$2

# return 1 if the dir exists in the archive
if [[ $(cat $archive_path | grep "^directory\s${directory}$") ]];
then
	echo "1"
else
	echo "0"
fi