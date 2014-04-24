#!/bin/bash

ROOT_UID="0"
if [ "$UID" -ne "$ROOT_UID" ] ; then
	echo "You must have root privileges to run this script..."
else
interface=$1

if [ -z $1 ]
then
	echo "Invalid arguements..."
	echo "Run script as ./remove_tc.sh [interface]"
else
	tc qdisc del dev $interface root

fi
fi
