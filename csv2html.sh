#!/bin/bash

delimiteur=';';
tri=1;

#On parcours la liste des arguments passés en paramètre
for i in $@
do
	case ${i} in
		-d?)					#Option pour le délimiteur
			delimiteur=${i:2};
		;;
		-s*)					#Option pour le tri par numero de colonne
			tri=${i:2};
		;;
		-S*)					#Option pour le tri par nom de colonne
			tri=$(head -n 1 | tr ";" "\n" | grep ${i:2} -n | cut -d: -f1);		#retourne le numero de colonne dans tri
		;;
	esac
done

i=0;
echo "<table>";
(head -n 1 && tail -n +2 | sort -t$delimiteur -k$tri) | while read line		#Entree standard avec entête fixe
do
	if ((i==0))
    then
    	echo '<tr><th>'$line'</th></tr>' | (sed s/$delimiteur/'<\/th><th>'/g)
		i=$(($i+1));
    else
		echo '<tr><td>'$line'</td></tr>' | (sed s/$delimiteur/'<\/td><td>'/g)
    fi
done
echo "</table>";
