#!/bin/bash
led=8
capteur=7
gpio mode $capteur in
echo -e "Vérification des broches..."
gpio mode $led out
gpio write $led 0

for (( i = 0; i < 5; i++ )); do
gpio toggle $led
sleep 1
done
 #Attend le démarrage du raspberry...

for (( i = 0; i < 30; i++ )); do
gpio toggle $led
sleep 0.05
done
gpio write $led 1
state=`gpio read $capteur`

while [[ 1 ]]
do
	echo "while"
	if [[ $state = "1" ]]; then

		echo "Caméra : a l'endroit"
		streaming-gstreamer 0 noReverse
	fi

	while [[ $state = "1" ]]
	do

		state=`gpio read $capteur`
		echo $state

		if [[ $state = "0" ]]; then
			echo "break"
			streaming-end
			sleep 1
		fi


	done



	if [[ $state = "0" ]]; then
		echo "Caméra : a l'envers"
		streaming-gstreamer 0 reverse
	fi

	while [[ $state = "0" ]]
	do
		state=`gpio read $capteur`
		echo $state

		if [[ $state = "1" ]]; then
			echo "break"
			streaming-end
			sleep 1
		fi
	done

done
