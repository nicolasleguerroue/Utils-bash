#!/bin/bash

echo -e "Start"

for a in $(seq 40); do xdotool key Num_Lock;sleep .01; xdotool key Caps_Lock;sleep .01; done