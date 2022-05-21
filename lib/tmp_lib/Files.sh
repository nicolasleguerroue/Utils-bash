#!/bin/bash

function InitLocation() {
	_localisation=$1
}


function CheckFiles() {

	_missing_file=()
	_error=0
   	array=("$@")
   	for element in "${array[@]}"; 
   	do
		if [ ! -s "$_localisation/$element" ]; then #si dossier non présent, ajoute le à la liste des fichiers manquants
	 	_missing_file[$error]=$element
		error=`expr $error + 1`
	 	fi
	done
} #Fin CheckFiles

function GetMissingFiles() {
	echo "${_missing_file[@]}"
} #retourne un tableau....

#fin MsgBox
