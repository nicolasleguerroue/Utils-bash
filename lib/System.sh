#!/bin/bash

function GetUser() {
	echo -e $USER
}

function GetShell() {
	echo -e $SHELL
}

function GetSession() {
	echo -e $SESSION
}


function GetSessionType() {
	echo -e $SESSIONTYPE
}

function GetStartTime() {
	echo -e $(who --boot)
}

function GetTimeActivity() {
	echo -e $(uptime -p)
}

function GetNumberUsers() {
	echo -e $(who -qH)
}

function fileExist() {

	if [[ -f $1 ]]; then
		return "0"
	else
		return "1"
	fi
}

function quit () {

	sudo umount /media/$USER/*
	#sudo rm -R /media/$USER/*

}