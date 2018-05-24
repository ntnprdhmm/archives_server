archives_path="server/archives/"

# start by checking if the file exists
# if not, return an error code
if [ ! -f $archives_path$1 ];
then
	echo "-1"
	exit 1
fi

# extract the root
root=$(cat $archives_path$1 | grep -m 1 "^directory\s" | cut -d " " -f 2)

echo $root
