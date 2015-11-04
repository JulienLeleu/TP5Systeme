path=$1

tab=($(ls $path));
i=0;
echo "<ul>";
for (( i = 0; i < ${#tab[*]}; i++ )); do
	echo "	<li>";
	if ! test -z $(echo ${tab[$i]} | egrep -o .csv$)
	then
		echo "		<a href=\"$path/html/${tab[$i]}\">${tab[$i]}</a>";
	elif ! test -z $(echo ${tab[$i]} | egrep -o .txt$)
	then
		echo "		<a href=\"$path/html/${tab[$i]}\">${tab[$i]}</a>";
	elif test -d $path/$tab[$i]
	then
		echo "		<a href=\"$path/html/${tab[$i]}\">${tab[$i]}</a>";
	else
		echo "		<a href=\"$path/contenu/${tab[$i]}\">${tab[$i]}</a>";
	fi
	echo "	</li>";
done
echo "</ul>";