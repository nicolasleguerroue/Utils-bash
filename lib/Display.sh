#!/bin/bash
#Variable utilisée par le script
_width=0
_height=0
_title=""
_compteur=0
_message=""
_temps=0
_message_end_enable=0
default_no=""


function InitSize() { #InitSize width height

if [[ -z $1 ]]; then
	_width=50
fi
if [[ -z $2 ]]; then
	_height=50
fi
_width=$1
_height=$2
}

function InitTitle() { #InitSize width height

if [[ -z $1 ]]; then
	_title="No_Title"
fi
_title=$1
}

function InitTimeMessageEnd() {

_time_message_end=$1
if [[ -z $1 ]]; then
	_time_message_end=1
fi	
}

function InitMessageEnd() {

_message_end=$1
if [[ -z $1 ]]; then
	_message_end="Finished"
fi	
_message_end_enable=1
}

function NoMessageEnd() {
	_message_end_enable=0
}



function ProgressBar() { #ProgressBar message time step

_compteur=0
_message=$1
_temps=$2
_step=$3

if [[ -z $1 ]]; then
	_message="Verification..."
fi
if [[ -z $2 ]]; then
	_temps=2
fi
if [[ -z $3 ]]; then
	_step=10
fi

DIALOG=${DIALOG=dialog}

_percent=$(echo "(100/$_step)" | bc)
_temps=$(echo "scale=2;($_temps/$_step)" | bc -l)
_total=$(echo "(100+$_percent)" | bc -l)
_avancement=0
(
while test $_compteur != $_total
do 
echo $_compteur
echo "XXX"
echo "$_message"
echo "XXX"
_compteur=`expr $_compteur + $_percent`
sleep $_temps
_avancement=$(echo "($_avancement+1)" | bc -l)
if [[ $_avancement = $(($_step+1)) ]]; then
	_compteur=$_total	
fi
done
) | $DIALOG --title "$_title" --gauge "$_message" $_width $_height 0 #o correspond 
if [[ $_message_end_enable == 1 ]]; then
	ProgressBarLocked "$_message_end" $_time_message_end 100
fi

}
#fin ProgressBar

function ProgressBarLocked() { #ProgressBarLocked message time percent

_message_2=$1
_temps_2=$2
_percent_2=$3
if [[ -z $1 ]]; then
	_message_2=$_message_end
fi
if [[ -z $2 ]]; then
	_temps_2=1
fi
if [[ -z $3 ]]; then
	_percent_2=100
fi


DIALOG=${DIALOG=dialog}
_wait=0

(
while test $_wait == 0
do 
echo "$_percent_2"
echo "XXX"
echo "$_message_2"
echo "XXX"
_wait=1
sleep $_temps_2
done
) | $DIALOG --title "$title" --gauge "$_message_2" $_width $_height $_percent_2 #o correspond 

} #fin ProgressBar

function MsgBox() { #MsgBox message

_message=$1
if [[ -z $1 ]]; then
	_message="any message..."
fi

DIALOG=${DIALOG=dialog}
$DIALOG --title "$_title" --clear \
        --msgbox "$_message" $_width $_height

} #fin MsgBox

function YesNo() { #YesNo message

_message=$1
if [[ -z $message ]]; then
	message="any message..."
fi
DIALOG=${DIALOG=dialog}
$DIALOG --title "$_title" --clear \
        --yesno "$_message" $_width $_height \
        
read=$?
if [[ $? = 255 ]]; then #Appuie sur echap
	MsgBox "Interruption de programme"
	exit
fi
if [[ $read = "1" ]]; then #Appuie sur annuler (non)
	_answer=0
fi
if [[ $read = "0" ]]; then #Appuie sur OK (oui)
	_answer=1
fi

}

function GetYesNo() {
	echo $_answer
}

function SetNo() {
default_no="--defaultno"
}


function InputBox() { #InputBox message
_message=$1
DIALOG=${DIALOG=dialog}
$DIALOG --clear --title "$_title" \
--inputbox "$_message" $_width $_height 2> Settings/input.txt

}

function InitMenuMessage() {

if [[ -z $1 ]]; then
	_message_menu="No_message"
fi
_message_menu=$1

}

function Menu() { #Menu message table ("id" "name" "id" "name"...) 

table=("$@")
last_number=$(echo "(${#table[@]}/2+1)" | bc)
if [[ -z $1 ]]; then
	table=("No id" "no message")
fi
length=$(echo "(${#table[@]}+1)" | bc)
#message_end2=$3
#redirection=$4

DIALOG=${DIALOG=dialog}
$DIALOG --clear --title "$_title" \
--menu "$_message_menu" 50 50 $length \
"${table[@]}" \
"" "" 

} #fin Menu

function GetMenu() {
 echo `cat Settings/file`	
}

function GetInputBox() {
 echo `cat Settings/input.txt`
}


#fin MsgBox

function DisplayNetwork() {
	InitSize 50 50
	InitTitle "Network scanning"
	InitMessageEnd "Scanning is over"
	InitTimeMessageEnd 1
	while [[ -z `hostname -I` ]]; do
	ProgressBar "Waiting for network" 10 50
	done
}
