#!/bin/bash

# check https://wiki.projetknl.eu/doku.php?id=ubuntuinstall for more information

##### --------------- modifiable variables
#sdk folder name after extraction // cannot be deduced from the archive name
sdkFolderName="sdk_elec"

##### --------------- Functions
function rmTemp {
	rm -f $sdkFileName
	rm -f $cortexMEmuFileName
	rm -Rf $sdkFolderName/
}

function endProg {
	rmTemp
	exit
}

function errorOccured {
	errMsg="$1"
	if [ -z "$errMsg" ]; then
		errMsg="no more information"
	fi
	echo -e "\nAn error occured : $errMsg"
	echo -e "\nInstallation failed : EXIT"
	endProg
}


##### --------------- Main

##### Paths

#bashrc path
bashrcPath="$HOME/.bashrc"

#default installation path
installPath="$HOME/Softs/micP"

#current dir
curDir=$(pwd)

##### links

#sdk
sdkDownloadLink="https://wiki.projetknl.eu/sdk_elec_lite.tar.gz"
sdkFileName="${sdkDownloadLink##*/}"


##### bashrc
addToBashrcl0="export SDK_ELEC=$installPath/sdk_elec"
addToBashrcl1="PATH=\$PATH:\$SDK_ELEC/bin/"
addToBashrc="$addToBashrcl0\n$addToBashrcl1"


#----------------------------------------------------------

####### Installation

##### dependancies

echo "Installing dependancies"
if ! sudo apt install make binutils-arm-none-eabi openocd gcc-arm-none-eabi libusb-0.1-4 libhidapi-hidraw0 wish  gdb-multiarch ; then
	errorOccured "Failed to install at least one dependancy"
fi

echo -e "\n-----------------------\n"

##### installation path
echo -e "Please enter \e[31;1mabsolute\e[0m installation path (use 0 for default path : $installPath):"
read tempinstallPath

#chose between custom or default installation path
if [ "$tempinstallPath" == "0" ] ; then
	mkdir -pv $installPath
else
	mkdir -pv $tempinstallPath
	installPath="$tempinstallPath"
fi


echo -e "\nInstall directory : $installPath"

echo -e "\n-----------------------\n"

##### Downloads

echo -e "Download files :\n"

#download sdk
if ! wget "$sdkDownloadLink" ; then
	#if error during download
	errorOccured "Failed to download $sdkFileName"
fi

echo -e "\n-----------------------\n"

#extract it
echo -e "Extracting files :"
if ! tar -zxvf "$sdkFileName" ; then
	#if error during extraction
	errorOccured "Failed to extract $sdkFileName"
fi

echo -e "\n-----------------------\n"

#copying it to installation path

echo -e "Copying $curDir/$sdkFolderName to $installPath/$sdkFolderName :\n"
if ! cp -rvf $curDir/$sdkFolderName $installPath ; then
	#if error during moving
	errorOccured "Failed to copy $curDir/$sdkFolderName to $installPath/$sdkFolderName"
fi

echo -e "\n-----------------------\n"

##### udev configuration

#copy rules
echo -e "Copying udev rules file :"

if ! sudo cp -v "$installPath/$sdkFolderName/share/openocd/contrib/60-openocd.rules" "/etc/udev/rules.d/" ; then
	#if error during extraction
	errorOccured "Failed to copy udev rules to /etc/udev/rules.d/"
fi

echo -e "\n-----------------------\n"

#reload rules
echo -e "Reloading udev rules"
if ! sudo udevadm control --reload ; then
	#if error while reloading
	errorOccured "Failed to reload udev rules"
fi

echo -e "\n-----------------------\n"

###### GDB link for tdb

echo -e "Create GDB link for tdb"
if [ ! -f /usr/bin/arm-none-eabi-gdb ] ; then
	if ! sudo ln -s /usr/bin/gdb-multiarch /usr/bin/arm-none-eabi-gdb ; then
		#if error when creating link
		errorOccured "Failed to create GDB link"
	fi
fi

echo -e "\n-----------------------\n"

##### Change user rights

echo -e "Changing user rights\nsudo usermod -aG dialout $USER"
if ! sudo usermod -aG dialout $USER ; then
	errorOccured "Failed to change user rights"
fi

echo -e "\n-----------------------\n"

##### Modifying bashrc

#bashrc
echo -e "Adding path variable to .bashrc\n"
echo "<.bashrc> path : $bashrcPath"

if ! grep -q "$addToBashrcl0" "$bashrcPath" && ! grep -q "$addToBashrcl1" "$bashrcPath"
then
	echo -e "Adding to bashrc :\n$addToBashrc"
	echo -e "\n$addToBashrc">>"$bashrcPath"
	#reloading bashrc
	source ~/.bashrc
else
	echo -e "<.bashrc> \e[31;1;4malready contains\e[0m :\n<$addToBashrc>"
fi

echo -e "\n-----------------------\n"


##### Qemu emulator

echo -e "Installing Qemu cortex M emulator :"
if ! sudo apt install qemu-system-arm ; then
	#if error during installation
	errorOccured "Failed to install Qemu cortex M emulator"
fi

##### Script end

echo -e "\nInstallation success\n"
endProg