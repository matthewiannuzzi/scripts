#!/bin/bash

ROOT_UID="0"
if [ "$UID" -ne "$ROOT_UID" ] ; then
	echo "You have root privileges to run this script..."

else
if [[ -z $1 || -z $2 || -z $3 || -z $4 ]]
then
    
    echo "Invalid arguements..."
    echo "Run script as ./tc_delay.sh [interface] [ipaddress] [subnet mask] [delay]"
else
        interface=$1
        ipaddress=$2
        subnet=$3
        delay=$4

        tc qdisc del dev $interface root

        tc qdisc add dev $interface root handle 1: prio

        tc filter add dev $interface parent 1:0 protocol ip pref 55 handle ::55 u32 match ip src ${ipaddress}/${subnet} flowid 2:1

        tc qdisc add dev $interface parent 1:1 handle 2: netem delay ${delay}ms

fi

fi
