#!/bin/bash
#v2.1- Added functions

#Displays the main menu to prompt for delay addition or removal
main_menu(){

echo "******************************************************"
echo "Select an option and press "enter":" 
echo "1) Add delay to a network"
echo "2) Remove delay from a network"
echo "******************************************************"
echo "Run script as ./tc_delay --help for more information" 
echo "******************************************************"
read delay_answer

case "$delay_answer" in
    1) add_delay
    ;;
    2) remove_delay
    ;;
    *) echo "Please enter a valid option..."
       main_menu  
    ;;
esac
}

#Gathers the interface, IP address, subnet, and delay and adds the delay respectively
add_delay(){
        echo "Please enter interface..."
        read interface
        echo "Please enter IP address..."
        read ipaddress
        echo "Please enter subnet..."
        read subnet
        echo "Please enter delay [ms]..."
        read delay
        echo "*********************************************************"
        echo "Please wait, adding ${delay}ms delay to $ipaddress/$subnet on interface $interface"
        echo "*********************************************************"
        
        tc qdisc del dev $interface root

        tc qdisc add dev $interface root handle 1: prio

        tc filter add dev $interface parent 1:0 protocol ip pref 55 handle ::55 u32 match ip src ${ipaddress}/${subnet} flowid 2:1

        tc qdisc add dev $interface parent 1:1 handle 2: netem delay ${delay}ms
}

#Removes any delay that is on the given interface
remove_delay(){
        echo "Please enter interface..."
        read interface
        
        echo "*********************************************************"
        echo "Please wait, removing ANY delay interface $interface"
        echo "*********************************************************"
        
        tc qdisc del dev $interface root
}


#Check for sudo..if no sudo, program will exit. If sudo is good, program will display main menu.
root_checker(){
ROOT_UID="0"
if [ "$UID" -ne "$ROOT_UID" ] ; 

then
	echo "You must have root privileges to run this script..."
    
else main_menu

fi #end if statement for root check/display main menu
}

help_checker(){
if [[ $1 = "--help" ]]
then
    echo "Run the program with no arguements to enter the main menu. Root privilege is required to add or remove delay."
else
    root_checker 
fi #end if statement for --help checker
}

help_checker

