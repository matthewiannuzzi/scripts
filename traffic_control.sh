#!/bin/bash
#v2.2- Added logging

help=$1
log_path=~/scripts/traffic_control_log.txt
pre_date="./predate.sh"

#Displays the main menu to prompt for delay addition/removal
main_menu(){
    echo "******************************************************"
    echo "Select an option and press "enter":" 
    echo "1) Add delay to a network"
    echo "2) Remove delay from a network"
    echo "******************************************************"
    echo "Run script as ./traffic_control.sh --help for more information" 
    echo "******************************************************"
    read delay_answer

    case "$delay_answer" in
        1) add_delay
        ;;
        2) remove_delay
        ;;
        *) echo""
           echo "Please enter a valid option..."
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
    echo "Please enter subnet cidr without '/'..."
    read subnet
    echo "Please enter delay [ms]..."
    read delay
    echo "*********************************************************"
    echo "Please wait, adding ${delay}ms delay to $ipaddress/$subnet on interface $interface"
    echo "*********************************************************"

    tc qdisc del dev $interface root 2>&1 | $pre_date >> $log_path

    tc qdisc add dev $interface root handle 1: prio 2>&1 | $pre_date >> $log_path

    tc filter add dev $interface parent 1:0 protocol ip pref 55 handle ::55 u32 match ip src ${ipaddress}/${subnet} flowid 2:1 2>&1 | $pre_date >> $log_path
    
    lastcommand=$(tc qdisc add dev $interface parent 1:1 handle 2: netem delay ${delay}ms 2>&1) 
    #Check if the previous command succeeded
    if [[ $? -eq 0 ]]; 
    then
        echo ""
        echo "Delay of ${delay}ms has successfully been added to $ipaddress/$subnet on interface $interface"
        echo ""
    else
        echo ""
        echo "Delay failed. Please see $log_path for more information."
        echo ""
    fi
    #Send errors from last command to log
    echo $lastcommand | $pre_date >> $log_path
}

#Removes any delay that is on the given interface
remove_delay(){
    echo "Please enter interface..."
    read interface

    echo "*********************************************************"
    echo "Please wait, removing ANY delay on $interface"
    echo "*********************************************************"
    
    #Remove the delay
    lastcommand=$(tc qdisc del dev $interface root 2>&1)
    
    #Check if the previous command succeeded
    if [[ $? -eq 0 ]]; 
    then
        echo ""
        echo "All delay has been removed from interface $interface"
        echo ""
    else
        echo ""
        echo "Removal of delay on interface $interface failed. Please see $log_path for more information."
        echo ""
    fi
    #Send errros from last command to log
    echo $lastcommand | $pre_date >> $log_path
}


#Check for sudo..if no sudo, program will exit. If sudo is good, program will display main menu.
root_checker(){
    ROOT_UID="0"
    if [ "$UID" -ne "$ROOT_UID" ] ; 
        then
            echo "You must have root privileges to run this script..."
            echo "`date` INVALID SUDO USER: `whoami`" >> $log_path
        else main_menu

    fi #end if statement for root check/display main menu
}

#Check if the --help flag is passed as an arguement
help_checker(){
    if [[ $help == '--help' ]] 
        then
            echo "Run the program with no arguements to enter the main menu. Root privilege is required to add or remove delay."
            echo "Log file: $log_path"
        else
            root_checker 
    fi #end if statement for help checker
}

help_checker
