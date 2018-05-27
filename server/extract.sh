archive_name=$1
archive_path="server/archives/$1"

# if the archive doesn't exists, return an error code
# else return the content of the archive

if [ ! -f $archive_path ];
then
	echo "-1"
	exit 1
fi

cat $archive_path
