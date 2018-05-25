# $1 => the current dir
# s2 => a relative path
# this script apply the given relative path to the current dir
# and echo the result

new_dir=$1
relative_path=$2

parts=(${relative_path//\// })

# handle ".." parts
i=0
while [[ i -lt ${#parts[@]} ]];
do
	if [[ ${parts[i]} == ".." ]];
	then
		new_dir=$(dirname $new_dir)
		if [[ $new_dir != "/" ]];
		then
			new_dir="$new_dir/"
		fi
	else
		new_dir="$new_dir${parts[i]}/"
	fi
	i=$(($i+1))
done

echo $new_dir