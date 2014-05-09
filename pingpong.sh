#!/bin/bash
echo "Enter a subnet to scan [x.x.x]: "
read subnet

pinging()
{
  ping -c 1 $1 > /dev/null
  [ $? -eq 0 ] && echo Host with IP: $i is up.
}


pong(){
for i in ${subnet}.{1..255} 
do
pinging $i & disown
done
}


pong 