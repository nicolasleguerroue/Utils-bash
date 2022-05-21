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
lib_man_directory="lib/man"									#Emplacement des manuels des commandes des bilbiothèques
command_man_directory="alias_man"									#Emplacement des manuels des commandes
command_directory="alias"									#Emplacement des commandes exécutables
storage="$HOME/.Utils"										#Emplacement où seront stockées les données du logiciel
alias_file="$HOME/.bash_aliases" 									#Emplacement du fichier alias système
env_file="$HOME/.profile" 									#Emplacement du fichier des variables d'environnement
file_import_lib="include_sources.sh" 						#Emplacement du fichier d'importation des bibliothèques
backup_directory="backup" 									#Emplacement du dossier de sauvegarde de .profile et .bashrc
tmp_profile=".tmp_profile"									#Nom du fichier temporaire de restauration de .profile
tmp_bashrc=".tmp_bashrc"									#Nom du fichier temporaire de restauration de .bashrc0x88="0xf88"												#Cible des lignes ajoutées par Utils dans les fichiers de conf
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
function addMessage {
	message="$1"
	if [ -z "$message" ]; then
		message="default message"
	fi
	echo -e $message
}
function addError {
	error="$1"
	if [ -z "$error" ]; then
		error="default error"
	fi
	echo -e $error
	echo -e "Interruption du programme..."
	exit
}
function install {

	if sudo apt-get install -y $1; then
		addMessage ">>> Installation de $1 : [ $green OK $default ]"
		#notify-send -t 500 "Installation de $1 : [ OK ]" &
	else
		addError ">>> Installation de $1 : [ $red FAIL $default ]"
		#notify-send -t 500 "Installation de $1 : [ FAIL ]" &
	fi

}

function print {
	echo -e $1
}


##################################################################################################################
#Vérification du dossier d'installation
##################################################################################################################
if [[ ! -d $storage ]]; then #Si le dossier n'existe pas, on l'installe

	if [[ $(hostname -I) == "" ]]; then #Si réseau, on passe

		echo -e "État du réseau : [ $red FAIL $default ]"	
		echo -e "Impossible d'installer les paquets sans réseau"	
		echo -e "Interruption du programme"	
		exit
	fi

	#header info file
	echo -e "### Résumé d'installation" > $resume_output
	echo -e "### A $(GetTime)" >> $resume_output

	echo -e "Création du répertoire source [$storage]..."
	mkdir $storage
	echo -e "Création du répertoire source [$storage] : [ $green OK $default ]"
	echo -e "\n>>> Répertoire du logiciel : $storage\n" >> $resume_output



	echo -e "Copie du code source vers $storage..."
	sudo cp -R ../$source_files/* $storage 
	echo -e "Copie du code source vers $storage : [ $green OK $default ]"


	echo -e "Création des alias des commandes courantes ..."
	echo -e "#Ajout des alias automatiques [$(GetTime)] - Nicolas LE GUERROUE #0x88" >> $alias_file
	echo -e ">>> Ajout des alias de commandes dans le fichier $alias_file : \n " >> $resume_output
	for directories in $(ls $storage/$command_directory); do

		
		path="$storage/$command_directory/$directories"
		if [ -d $path ]; then
			
			for files_command in $(ls $path); do
				echo -e "alias $files_command='$path/$files_command'  #0x88" >> $alias_file  #0x88 est une clé pour retrouver les lignes du fichier bashrc modifiées par Utils
				echo -e "$files_command='$path/$files_command'" >> $resume_output
			done
		fi
	done
	echo -e "#Fin de l'ajout des alias automatiques #0x88" >> $alias_file
	echo -e "Création des alias des commandes courantes : [ $green OK $default ]"


	echo -e "Mises à jours des pages du manuel (man) des bibliothèques..."
	echo -e "\n>>>Mises à jours des pages du manuel (man) des bibliothèques : \n" >> $resume_output
	for man_file in $(ls $storage/$lib_man_directory); do
		sudo cp $storage/lib/man/$man_file /usr/share/man/man7
		sudo gzip /usr/share/man/man7/$man_file
		echo -e "man $man_file" >> $resume_output
	done
	echo -e "Mises à jours des pages du manuel (man) des bibliothèques  : [ $green OK $default ]"

	echo -e "\n>>>Mises à jour des manuels de commandes: \n" >> $resume_output
	for man_file in $(ls $storage/$command_man_directory); do
		sudo cp $storage/alias_man/$man_file /usr/share/man/man7
		sudo gzip /usr/share/man/man7/$man_file
		echo -e "man $man_file" >> $resume_output
	done
	echo -e "Mises à jours des pages du manuel (man) des commandes  : [ $green OK $default ]"

	sudo mandb 				#mise à jour des pages de manuel


	echo -e "Création des fichiers système..."

	echo -e "" > $storage/$tmp_profile #fichier de restauration .profile


	if [[ ! -f $storage/$standard_output ]]; then
		touch $storage/$standard_output
	fi
	sudo chmod 777 $storage/$standard_output

	#Si le fichier des erreurs n'existe pas, on le créer
	if [[ ! -f $storage/$errors_output ]]; then
		touch $storage/$errors_output
	fi
	sudo chmod 777 $storage/$errors_output
	echo -e "Création des fichiers système : [ $green OK $default ]"


	echo -e "Création du fichier d'inclusion des sources..."

	sudo chmod 777 $storage/$file_import_lib

	echo -e "#!/bin/bash" > $storage/$file_import_lib
	echo -e "#Include all lib with .sh format" >> $storage/$file_import_lib
	echo -e "for bash_files in \$(ls $HOME/.Utils/lib | grep '.sh'); do" >> $storage/$file_import_lib
	echo -e "	source $HOME/.Utils/lib/\$bash_files" >> $storage/$file_import_lib
	echo -e "done" >> $storage/$file_import_lib

	echo -e "Création du fichier d'inclusion des sources : [ $green OK $default ]"
	echo -e "\n>>> Création du fichier d'inclusion des sources effectuée [$storage/$file_import_lib]" >> $resume_output




	echo -e "Vérification de la variable d'environnement UTILS..."
	if [[ $(cat $HOME/.profile | grep 'UTILS') = "" ]] 
	then
		echo -e "La variable d'environnement \$UTILS n'existe pas"
		echo -e "Copie du fichier .profile..."
		echo -e "\n>>>Copie du fichier $HOME/.profile vers le fichier $HOME/.profile_save_Utils" >> $resume_output
		touch $HOME/.profile_save_Utils
		cat $HOME/.profile >> $HOME/.profile_save_Utils

		echo -e "UTILS=$storage/$file_import_lib" >> $env_file  #

	else
		echo "La variable d'environnement \$UTILS existe déja"
	fi
	echo -e "\n>>> Variable d'environnement \$UTILS='$storage/$file_import_lib'" >> $resume_output

	source ~/.profile
	source ~/.bashrc

	echo -e "Mise à jour des droits..."
	sudo chmod 777 -R $storage
	echo -e "Mise à jour des droits : [ $green OK $default ]"


	#Installation de Zenity
	#vérification réseau...
	echo -e "Vérification de l'état du réseau..."
	if [[ $(hostname -I) != "" ]]; then #Si réseau, on installe zenity

		echo -e "État du réseau : [ $green OK $default ]"

		install snap
		install zenity
		install tree
		install hardinfo
		install zip
		install python3-pip
		install okular


		echo -e "### Fin du résumé d'installation" >> $resume_output
		#TextInfos "$resume_output"  2>> $errors_output >> $standard_output 

		SetTitle "Utilisation de la bibliothèque Utils"
		PrintFile "Readme.md"  2>> $errors_output >> $standard_output 
		SetSize 800 600
		Info "<b>bibliothèque Utils</b> - $(GetTime)\n
<b>Logiciel d'installation</b> \n
Le logiciel a bien été installé. Le dossier source se situe à l'emplacement $HOME/.$source_files \n
<u>Pour installer les logiciels, saississez dans un terminal :</u> 
<b>sudo utils-install</b> \n
<u>Pour ajouter des logiciels dans la base de données, saississez dans un terminal :</u>
<b>utils-add</b> \n
<u>Pour récuperer le code source, saississez dans un terminal :</u>
<b>utils-get</b> \n 
<u>Pour obtenir la documentation complète du logiciel, saississez :</u> \n
<b>utils-doc</b> [documentation avec interface graphique]\n\n
Il est possible d'obtenir la documentation des bilbiothèques avec la commande suivante : 
<b>utils-lib</b> \n 
<u>Version :</u> 1.0 
<u>Auteur :</u> Nicolas Le Guerroué - <i> nicolasleguerroue@gmail.com </i> \n"

	else

		while [[ -z `hostname -I` ]]; do  #Prévient le manque de réseau
			echo "En attente de réseau..."
			sleep 2
		done		
		echo -e "État du réseau : [ $red FAIL $default ]"	

	fi

else	#Sinon on demande à désinstaller le logiciel

	SetSize 400 200
	SetTitle "Désinstallation de Utils"
	if [[ $(Question "Le logiciel est déja installé, voulez-vous le désinstaller ? \n Cela supprimera l'intégralité des fichiers situés dans le répertoire $storage." 2>> $errors_output) == "1" ]]; then  2>> $errors_output >> $standard_output


		echo -e "Suppression des pages du manuel..."
		for man_file in $(ls $storage/$lib_man_directory); do
			sudo rm /usr/share/man/man7/$man_file.gz
		done
		for man_file in $(ls $storage/$command_man_directory); do
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
			if [[ $(echo $line | grep "0x88" ) = "" ]]; then
				echo $line >> $storage/$tmp_bashrc
			fi
		done <$alias_file
		echo -e "`cat $storage/$tmp_bashrc`" > $alias_file


		echo -e "Mises à jours des alias..."

		#shopt -s expand_aliases
		source ~/.profile
		source ~/.bashrc
		source ~/.bash_aliases

		for directories in $(ls $storage/$command_directory); do

			path="$storage/$command_directory/$directories"
			if [ -d $path ]; then
				for files_command in $(ls $path); do
					echo -e "Suppression de l'alias $files_command" 
				done
			fi
		done

		echo -e "Mises à jours des alias  : [ $green OK $default ]"
		source ~/.profile
		source ~/.bashrc
		source ~/.bash_aliases
	
		echo -e "Restauration du fichier $alias_file : [ $green OK $default ]"

		echo -e "Suppression du répertoire $storage..."
		sudo rm -R $storage	#suppression du dossier
		echo -e "Suppression du répertoire $storage : [ $green OK $default ]"

		SetSize 400 100
		Info "Le logiciel et toute ses dépendances ont été supprimées." 2>> $errors_output
	else
		exit
	fi

fi


