archives_path="server/archives/"

# if the file doesn't exists, return an error code
# else, extract the archive's root directory and return it

if [ ! -f $archives_path$1 ];
then
	echo "-1"
	exit 1
fi

root=$(cat $archives_path$1 | grep -m 1 "^directory\s" | cut -d " " -f 2)

echo $root
