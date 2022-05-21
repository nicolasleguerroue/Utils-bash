##################################################################################################################
#!/bin/bash
##################################################################################################################
#Gestionnaire d'installation Utils
#Cet utilitaire installe tous les scripts et fichiers néecessaires au bon fonctionnement de la bibliothèque Utils
#Auteur : Nicolas LE GUERROUE
#Date : 20 juin 2020 
##################################################################################################################
###################################### HEADER                    #################################################
##################################################################################################################
#Variables globales
##################################################################################################################
source_files="Utils" 										#Nom du répertoire de la bilbiothèque (Dossier courant)
errors_output="stderr_utils.log"							#Nom du fichier de sortie d'erreur
standard_output="stdout_utils.log"							#Nom du fichier de sortie standard
resume_output="resume_utils.log"							#Nom du fichier de sortie standard [résumé d'installation]
##################################################################################################################
#Emplacements des outils, scripts et marqueurs
##################################################################################################################
lib_directory="lib"											#Emplacement des bibliothèques Bash
lib_man_directory="lib/man"									#Emplacement des manuels des commandes
command_directory="alias"									#Emplacement des commandes exécutables
storage="$HOME/.Utils"										#Emplacement où seront stockées les données du logiciel
alias_file="$HOME/.bashrc" 									#Emplacement du fichier alias système
env_file="$HOME/.profile" 									#Emplacement du fichier des variables d'environnement
file_import_lib="include_sources.sh" 						#Emplacement du fichier d'importation des bibliothèques
backup_directory="backup" 									#Emplacement du dossier de sauvegarde de .profile et .bashrc
tmp_profile=".tmp_profile"									#Nom du fichier temporaire de restauration de .profile
tmp_bashrc=".tmp_bashrc"									#Nom du fichier temporaire de restauration de .bashrc
target="0xf88"												#Cible des lignes ajoutées par Utils dans les fichiers de conf
##################################################################################################################
#Importations des bilbiothèques nécéssaires pour l'installation
##################################################################################################################
source $lib_directory/Zenity.sh
source $lib_directory/Colors.sh
source $lib_directory/Time.sh
##################################################################################################################
#Initialisation de la fenêtre d'installation
##################################################################################################################
SetTitle "Utils Manager"
SetSize 800 800
##################################################################################################################
###################################### FIN HEADER                #################################################
##################################################################################################################

if [[ ! -d $storage ]]; then #Si le dossier n'existe pas, on l'installe

	echo -e "Impossible de supprimer un logiciel non installé."
	echo -e "exit()"
	exit

else
		SetSize 400 200

	if [[ $(Question "Le logiciel est déja installé, voulez-vous le désinstaller ? \n Cela supprimera l'intégralité des fichiers situés dans le répertoire $storage." 2>> $errors_output) == "1" ]]; then  2>> $errors_output >> $standard_output


		echo -e "Suppression des pages du manuel..."
		for man_file in $(ls $lib_man_directory); do
			sudo rm /usr/share/man/man7/$man_file.gz
		done
		echo -e "Suppression des pages du manuel : [ $green OK $default ]"


		echo -e "Restauration du fichier $env_file..."
		echo -e "" > $storage/$tmp_profile 
		while IFS= read -r line
		do
			if [[ $line != "UTILS=$storage/$file_import_lib" ]]; then
				echo  $line >> $storage/$tmp_profile
			fi
		done <$env_file
		echo -e "`cat $storage/$tmp_profile`" > $env_file
		echo -e "Restauration du fichier $env_file : [ $green OK $default ]"


		echo -e "Restauration du fichier $alias_file..."
		echo -e "" > $storage/$tmp_bashrc 
		while IFS= read -r line
		do
			#echo $line
			if [[ $(echo $line | grep $target ) = "" ]]; then
				echo $line >> $storage/$tmp_bashrc
			fi
		done <$alias_file
		echo -e "`cat $storage/$tmp_bashrc`" > $alias_file

		echo -e "Restauration du fichier $alias_file : [ $green OK $default ]"


		echo -e "Suppression du répertoire $storage..."
		sudo rm -R $storage	#suppression du dossier
		echo -e "Suppression du répertoire $storage : [ $green OK $default ]"


		Print "Le logiciel et toute ses dépendances ont été supprimées." 2>> $errors_output
	else
		exit
	fi

fi