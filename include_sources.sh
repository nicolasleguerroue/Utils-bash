#!/bin/bash
#Include all lib with .sh format
for bash_files in $(ls /home/nico/.Utils/lib | grep '.sh'); do
	source /home/nico/.Utils/lib/$bash_files
done
