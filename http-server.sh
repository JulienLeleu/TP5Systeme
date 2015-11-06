#!/bin/bash

findOption () {
	option=$1
	shift
	echo $* | egrep -o "($option .+)" | cut -d' ' -f2
}

valeursParDefaut () {
	if test -z $PORT
	then
		export PORT=8080;
	fi
	if test -z $CHEMIN1
	then
		export CHEMIN1=$HOME/public_html
	fi
	if test -z $CHEMIN2
	then
		export CHEMIN2=$HOME/modeles_html/modele.html
	fi
}

decompte () {
	decompte=3
	while test $decompte -gt 0
	do
		sleep 1
		echo -n "."
		decompte=$(($decompte-1))
	done
}

demarrerServeur () {
	echo -n "Démarrage du serveur "
	#decompte
	echo
	echo "Serveur lancé sur le port $PORT"
	echo "Lecture des fichiers depuis : $CHEMIN1"
	echo "Modele HTML : $CHEMIN2"
}

export PORT=$(findOption "-p" $*)
export CHEMIN1=$(findOption "-d" $*) #dossier dans lesquels se trouves les fichiers HTML
export CHEMIN2=$(findOption "-t" $*) #fichier contenant les modeles pour traduire les fichiers non HTML

valeursParDefaut
demarrerServeur

PATH=$(cd $(dirname $0) ; pwd):$PATH

tube=/tmp/requete
mkfifo $tube 2> /dev/null

while true
do
	cat $tube | ./http-request.sh | nc -p $PORT -l > $tube
done