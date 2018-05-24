archives_path="server/archives/"

archives_name=$1
location=$2

# if there is a / at the end of the location, remove it
if [[ ${location: -1} == "/" ]]; 
then
	location=${location::-1}
fi

archive_path=$archives_path$archives_name

# search the line number of this location
line=$(grep -n -m 1 $location $archive_path | cut -d ":" -f 1)

# get alls the line until the next @
nb_lines=$(wc -l $archive_path | cut -d " " -f 1)

cat $archive_path | tail $(($line - $nb_lines -1)) > temp.txt

while read line 
do 
	if [[ $line =~ "@" ]];
	then
		break
	fi
	echo $line
done < temp.txt