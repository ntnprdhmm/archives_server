archives_path="server/archives/"

archives_name=$1
directory=$2

archive_path=$archives_path$archives_name

match=$(cat $archive_path | grep "^directory\s${directory}$")

if [[ $match ]];
then
	echo "1"
else
	echo "0"
fi