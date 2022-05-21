#!/bin/bash
function GetImage() {
wget -qO $1.png "http://api.sat24.com/mostrecent/EU/visual5hdcomplete"


}