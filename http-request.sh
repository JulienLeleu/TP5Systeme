continuer=true 
envoyerReponse () {
	if test $1 != "exit"
	then
		echo "(/HTTP/1.1,200,\"OK\")"
		echo "reçu";
	fi
} 

verifChaine () {
	echo $@ | egrep "^GET .* HTTP/1.1$"
}

messageErreur () {
	if test $1 != "exit"
	then
		echo "Erreur 405"
		echo "http-request.sh: erreur: $1: 405: Méthode inconnue" 1>&2
	fi
}

sortir () {
	if test $1 = "exit"
	then
		echo "ON SORT !!!"
		exit #continuer=false
	fi
}

rediriger () {
	chaine=$( echo $1 | cut -d'/' -f2)
	#Si la chaine commence par /contenu/
	if test $chaine == "contenu"
	then
		chemin=$( echo $1 | sed -e 's/\/contenu\///1')
		#Si le contenu est un fichier régulier
		if test -f $CHEMIN1/$chemin
		then
			echo $(cat -e $CHEMIN1/$chemin)
		#Si le contenu est un dossier
		elif test -d $CHEMIN1/$chemin
		then
			echo "Erreur 406"
			echo "http-request.sh: erreur: $1: 406: Le fichier est un dossier" 1>&2
		fi

	#Si la chaine commence par /html/
	elif test $chaine == "html"
	then
		chemin=$( echo $1 | sed -e 's/\/html\///1')
		#Si le fichier est un CSV
		if ! test -z $(echo $1 | egrep -o .csv$)
		then
			cat $CHEMIN1/$chemin | ./csv2html.sh
		#Si le fichier est un fichier texte
		elif ! test -z $(echo $1 | egrep -o .txt$)
		then
			./txt2html.sh $CHEMIN1/$chemin
		#Si le fichier est un repertoire
		elif test -d $CHEMIN1/$chemin
		then
			./dossier2html.sh $CHEMIN1/$chemin
		#Si le fichier existe
		elif test -e $CHEMIN1/$chemin
		then
			echo "Erreur 406: Type de fichier inconnu"
			echo "http-request.sh: erreur: $1: 406: Type de fichier inconnu" 1>&2
		else
			echo "Erreur 404: La cible n'est pas présente"
			echo "http-request.sh: erreur: $1: 404: La cible n'est pas presente" 1>&2
		fi
	fi
}

afficherContenu () {
	if test $1 != "exit"
	then
		echo -e $1
	fi
}

while $continuer
do
	read chaineRecu
	chaine=$(echo $chaineRecu | cut -d' ' -f2)
	envoyerReponse $chaine
	(verifChaine $chaineRecu && rediriger $chaine) || messageErreur $chaine
	sortir $chaine
	afficherContenu $chaine
done