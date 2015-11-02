continuer=true
envoyerReponse () {
	if test $1 != "exit"
	then
		echo "(/HTTP/1.0,200,\"OK\")"
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
	fi
}

afficherContenu () {
	if test $1 != "exit"
	then
		echo $1
	fi
}

	read chaineRecu
	chaine=$(echo $chaineRecu | cut -d' ' -f2)
	envoyerReponse $chaine
	verifChaine $chaineRecu || messageErreur $chaine
	sortir $chaine
	afficherContenu $chaine
