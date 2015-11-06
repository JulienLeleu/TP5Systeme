continuer=true 

#Renvoie une reponse de confirmation de reception du message
envoyerReponse () {
	if test -z $(echo $1 | egrep -o ^exit$)
	then
		echo "(/HTTP/1.1,200,\"OK\")"
		echo "reçu";
	fi
} 

#Verifie si la chaine commence par GET et se termine par HTTP/1.1
verifChaine () {
	echo $@ | egrep "^GET .* HTTP/1.1$"
}

#trie les csv par colonnes
triepar () {
	fichier=$1
	optionDeTri=$2
	if [ -e $CHEMIN1/$fichier ]
	then
		if [ ! -z $(echo $1 | egrep -o .csv$) ]
		then
			if let $optionDeTri
			then
				cat $CHEMIN1/$fichier | ./csv2html.sh -s$optionDeTri
				echo "http-request.sh: info: $1: 200: Affichage du fichier CSV en HTML trié par numéro de colonne" 1>&2
			else
				cat $CHEMIN1/$fichier | ./csv2html.sh -S$optionDeTri
				echo "http-request.sh: info: $1: 200: Affichage du fichier CSV en HTML trié par nom de colonne" 1>&2
			fi
		else
			echo "Erreur 406: Cible non acceptable"
			echo "http-request.sh: erreur: $1: 406: Cible non acceptable" 1>&2
		fi
	else
		echo "Erreur 404: La cible n'est pas présente"
		echo "http-request.sh: erreur: $1: 404: La cible n'est pas presente" 1>&2
	fi
}

#Renvoie une erreur 405
messageErreur () {
	if test -z $(echo $1 | egrep -o ^exit$)
	then
		echo "Erreur 405"
		echo "http-request.sh: erreur: $1: 405: Méthode inconnue" 1>&2
	fi
}

#si l'instruction vaut "exit", on sort 
sortir () {
	if test $1 = "exit"
	then
		echo "ON SORT !!!"
		#echo "http-request.sh: info: $1: 200: Deconnexion du client" 1>&2
		continuer=false
		#exit
	fi
}

rediriger () {
	chaine=$( echo $1 | cut -d'/' -f2)
	#Si la chaine commence par /contenu/
	if test $chaine == "contenu"
	then
		chemin=$( echo $1 | sed -e 's/\/contenu\///1')
		#Si le contenu est un fichier régulier
		if [ -f $CHEMIN1/$chemin ]
		then
			echo $(cat -e $CHEMIN1/$chemin)
			echo "http-request.sh: info: $1: 200: Affichage du contenu du fichier" 1>&2
		#Si le contenu est un dossier
		elif [ -d $CHEMIN1/$chemin ]
		then
			echo "Erreur 406 : Le fichier est un dossier"
			echo "http-request.sh: erreur: $1: 406: Le fichier est un dossier" 1>&2
		fi

	#Si la chaine commence par /html/
	elif test $chaine == "html"
	then
		chemin=$( echo $1 | sed -e 's/\/html\///1')
		
		#Si on invoque la methode triepar sur un csv
		if [ ! -z $(echo $1 | egrep -o /html/.*/triepar/.*) ]
		then
			triepar $(echo $chemin | sed 's/\/triepar\// /g')
		#Si le fichier est un CSV
		elif [ -e $CHEMIN1/$chemin ] && [ ! -z $(echo $1 | egrep -o .csv$) ]
		then
			cat $CHEMIN1/$chemin | ./csv2html.sh
			echo "http-request.sh: info: $1: 200: Affichage du fichier CSV en HTML" 1>&2
		#Si le fichier est un fichier texte
		elif [ -e $CHEMIN1/$chemin ] && [ ! -z $(echo $1 | egrep -o .txt$) ]
		then
			./remplace-dans.sh < $CHEMIN1/$chemin $CHEMIN2
			echo "http-request.sh: info: $1: 200: Affichage du fichier texte en HTML" 1>&2
		#Si le fichier est un repertoire
		elif [ -d $CHEMIN1/$chemin ]
		then
			./dossier2html.sh $CHEMIN1/$chemin
			echo "http-request.sh: info: $1: 200: Affichage du dossier en HTML" 1>&2
		#Si le fichier existe quand même
		elif [ -e $CHEMIN1/$chemin ]
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
	if [ -z $(echo $1 | egrep -o ^exit$) ]
	then
		echo -e $1
	fi
}

#corps du programme
while $continuer
do
	read chaineRecu
	chaine=$(echo $chaineRecu | cut -d' ' -f2)
	envoyerReponse $chaine
	(verifChaine $chaineRecu && rediriger $chaine) || messageErreur $chaine
	sortir $chaine
	afficherContenu $chaine
done
