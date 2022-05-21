#!/bin/bash
### Méthodes

# SetTitle "Titre"
# Help
# Print 'Message de '


#variable internes
_width=400
_height=400
_title="Logiciel"

red_zenity="color=\"red\""

#Barre de progression
_progress_bar_end="--auto-close"

#Entry
_message_entry="Message de l'entrée : ligne 12"

#Liste
_message_list="Message de la liste  : ligne 17"
_columns_list=""


#Checkbox
_message_checkbox="Checkbox [void]"
_columns_checkbox=""

#Radio
_message_radio="radio [void]"
_columns_radio=""

#text-infos
_message_text="[void]"


root_server="/var/www/html/"
root_web="Serveur-Nicolas"

function Help() {

	echo "
	SetTitle 'Titre'  : définit le titre de la fenetre  
	Print 'message' :affiche une fenetre de message  
	ProgressBar 'message' temps_total n : affiche une barre de progression de temps_total divisé en n pas 
	NoBlockProgressBar : (void) passe à la suite lorsque la barre de progression est terminée  
	BlockProgressBar : (void) ne passe pas à la suite lorsque la barre de progression est terminée  
	DisplayNetwork : (void) attend une connexion web  
	
	SetTextEntry 'texte' ; définit le texte d'une entrée (input) 
	SetDefaultEntry 'texte' : définit le texte par défaut  
	Entry : affiche l'entrée  
	Question 'texte' : pose une question (ou ou non) 

	SetTextList 'texte' : définit le texte pour une Liste  
	SetColumnsList 'colonne1' 'colonne2' ... : définit les colonnes de la Liste
	List 'var1' var2 'var3' : définit le contenu de la liste  

	SetTextCheckBox 'texte' : définit le texte pour une CheckBox  
	SetColumnsCheckBox 'colonne1' 'colonne2' ... : définit les colonnes de la CheckBox
	CheckBox 'var1' var2 'var3' : définit le contenu de la CheckBox


	SetTextRadio 'texte' : définit le texte pour une Radio  
	SetColumnsRadio 'colonne1' 'colonne2' ... : définit les colonnes de la Radio
	Radio 'var1' var2 'var3' : définit le contenu de la Radio   -> La 1ere variable doit etre TRUE ou FALSE
	"
}

function SetTitle() {  #setTtitle "Gestionnaire"
_title=$1
}

function SetSize() { #setSize 20 20
	_width=$1
	_height=$2
}


function BlockProgressBar() {
	_progress_bar_end=""
}

function NoBlockProgressBar() {
	_progress_bar_end="--auto-close"
}


function ProgressBar() {

_compteur=0
_message=$1
_temps=$2
_step=$3

_percent=$(echo "(100/$_step)" | bc)
_temps=$(echo "scale=2;($_temps/$_step)" | bc -l)
_total=$(echo "(100+$_percent)" | bc -l)
_avancement=0


(
while test $_compteur != $_total
do 
	echo $_compteur #instruction obligatoire !
	sleep $_temps
	_compteur=`expr $_compteur + $_percent`
	_avancement=$(echo "($_avancement+1)" | bc -l)

	if [[ $_avancement = $(($_step+1)) ]]; then
		_compteur=$_total
	fi
done
) | 
zenity --progress \
  --title="$_title" \
  --text="$1" \
  --percentage=0 \
  $_progress_bar_end


}

function DisplayNetwork() {
	SetTitle "Network scanning"
	while [[ -z `hostname -I` ]]; do
	ProgressBar "Waiting for network" 5 100
	done
}

function SetTextEntry() {
	_message_entry=$1
}

function SetDefaultEntry() {
	_default_element=$1
}

function Entry() {
	zenity --entry --title="$_title" --entry-text="$_default_element" --text="$_message_entry" $@
	_default_element=""
}

function Question() {
zenity --question \
--title "$_title" \
--text "$1" \
--width=$_width \
--height $_height

if [ $? = 0 ]
then
	echo "1" #true
else
	echo "0" #false
fi
}

function SetTextList() {
	_message_list="$1"
}


function SetColumnsList() { #SetColumns "ID" "NAME" "FILENAME"
a=""
b=""
table=("$@") #tableau 
for i in "${table[@]}"
do
a="--column=$i";
b="$b $a" #Concaténation
done
_columns_list=$b


}


function List() { #List 
zenity --list \
		--text="$_message_list" \
		--title="$_title" \
		--width=$_width \
		--height $_height \
          $_columns_list \
          "$@"
}






function SetTextCheckBox() {
	_message_checkbox="$1"
}
function SetColumnsCheckBox() { #SetColumns "ID" "NAME" "FILENAME"
a=""
table=("$@") #tableau 
for i in "${table[@]}"
do
a="--column=$i";
b="$b $a" #Concaténation
done
_columns_checkbox=$b
}

function ResetColumsCheckBox() {
_columns_checkbox=""
_message_checkbox=""
echo "RESET"
}


function CheckBox() { #List 
zenity --list \
		--text="$_message_checkbox" \
		--title="$_title" \
		--width=$_width \
		--height $_height \
		--checklist \
          $_columns_checkbox \
          "$@"
}





function SetTextRadio() {
	_message_radio="$1"
}
function SetColumnsRadio() { #SetColumns "ID" "NAME" "FILENAME"
a=""
table=("$@") #tableau 
for i in "${table[@]}"
do
a="--column=$i";
b="$b $a" #Concaténation
done
_columns_radio=$b
}


function Radio() { #List 
zenity --list \
		--text="$_message_radio" \
		--title="$_title" \
		--width=$_width \
		--height $_height \
		--radiolist \
          $_columns_radio \
          "$@"
}



function PrintFile() {
zenity --text-info \
		--text="$_message_text" \
		--title="$_title" \
		--width=$_width \
		--height $_height \
		--filename=$1
        
}

# SetTitle "RANDOM"
# TextInfos "test.txt"

function GetFile() {
zenity --file-selection \
		--title="$_title" \
		--width=$_width \
		--height=$_height
        
}

function Info() {  #print "Informations" 
	zenity --title="$_title" \
	--width=$_width \
	--height=$_height \
	--info \
	--text="<span>$1</span>" 
}

function Warning() {
zenity --warning \
		--title="$_title" \
		--text="$@" \
		--width=$_width \
		--height=$_height 
        
}

function Error() {
zenity --error \
		--title="$_title" \
		--text="$@" \
		--width=$_width \
		--height=$_height 
        
}

function Scale() {
zenity --scale \
		--title="$_title" \
		--text="$4" \
		--width=$_width \
		--height=$_height \
		--min-value=$1 \
		--max-value=$2 \
		--value=$3
        
}

function Password() {
zenity --password \
		--title="$_title" \
		--text="$@" \
		--width=$_width \
		--height=$_height
        
}


# SetTitle "Test"
# SetSize 800 200 
# Info "TEST"
#GetFile <
# Error "ERREUR"
# Warning "WArning"
# PrintFile "Zenity.sh"
#Password
#Scale 18 120 18 "Age"
