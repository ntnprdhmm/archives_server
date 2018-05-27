archive_path="server/archives/$1"
directory=$2

# if there is a / at the end of the directory, remove it
if [[ ${directory: -1} == "/" ]]; 
then
	directory=${directory::-1}
fi

# search the line number of the directory's declaration in the archive
line=$(grep -n -m 1 $directory $archive_path | cut -d ":" -f 1)

# count the number of line of this archive
nb_lines=$(wc -l $archive_path | cut -d " " -f 1)

# cut the archive content => start at the directory's declaration
# == at line $line
cat $archive_path | tail $(($line - $nb_lines -1)) > temp.txt

# read all the children of the directory (== until the next @)
while read line 
do 
	if [[ $line =~ "@" ]];
	then
		break
	fi
	echo $line
done < temp.txt