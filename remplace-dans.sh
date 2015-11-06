#!/bin/bash

patternDebut="<!--DEBUT-->"
patternFin="<!--FIN-->"

corps=$(cat);

modele=$1

cat $modele | sed -e "/^$patternDebut$/i$(echo $corps)" -e "/^$patternDebut$/,/^$patternFin$/d";

#cat | sed -e "/^--DEBUT_REMPLACEMENT--$/i$(echo $corps)" -e "/^--DEBUT_REMPLACEMENT--$/,/^--FIN_REMPLACEMENT--$/d";


#2e solution
#cat | sed "/--DEBUT_REMPLACEMENT--/,/--FIN_REMPLACEMENT--/ s/.*/$corps/" | uniq;