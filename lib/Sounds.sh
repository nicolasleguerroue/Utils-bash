#!/bin/bash

_state=""

function SetMachine() {
	if [[ $1 == "Computer" ]]; then
		_state="Computer"
	fi

	if [[ $1 == "Raspberry" ]]; then
		_state="Raspberry"
	fi
}

function Speech() {

	if [[ $_state == "Computer" ]]; then
		echo -e "$*" | festival --tts --language "english"
	fi

	if [[ $_state == "Raspberry" ]]; then
		pico2wave -l=fr-FR -w=.fichier.wav "$*" && play .fichier.wav
	fi
	
}