#!/bin/bash
#v2.5- Added logging & root check improvements


help=$1
log_path=~/log.txt

#accept stdin and echo with date: stdin
predate(){
    while read line
    do
        echo $(date) ":" $line;
    done
}

#Displays the main menu to prompt for delay addition/removal
main_menu(){
    echo "****************************************************************"
    echo "Select an option and press "enter":" 
    echo "1) Add delay to a network"
    echo "2) Remove delay from a network"
    echo "****************************************************************"
    echo "*Run script as ./traffic_control.sh --help for more information*" 
    echo "****************************************************************"
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
    echo "Enter interface..."
    read interface
    echo "Enter IP address..."
    read ipaddress
    echo "Enter subnet cidr without '/'..."
    read subnet
    echo "Enter desired delay [ms]..."
    read delay
     
    tc qdisc list | grep netem >> /dev/null
    if [[ $? -eq 0 ]];
        then
            tc qdisc del dev $interface root 2> predate >> $log_path
            echo "Previous latency on interface $interface has been removed."
        else 
            echo "No previous latency on interface $interface detected"
    fi

    echo "************************************************************************************"
    echo "*Please wait, adding ${delay}ms delay to $ipaddress/$subnet on interface $interface*"
    echo "************************************************************************************"

    tc qdisc add dev $interface root handle 1: prio 2>&1 | predate >> $log_path

    tc filter add dev $interface parent 1:0 protocol ip pref 55 handle ::55 u32 match ip src ${ipaddress}/${subnet} flowid 2:1 2>&1 | predate >> $log_path
    
    lastcommand=$(tc qdisc add dev $interface parent 1:1 handle 2: netem delay ${delay}ms 2>&1) 
    #Check if the previous command succeeded
    if [[ $? -eq 0 ]]; 
    then
        echo ""
        echo "Delay of ${delay}ms has successfully been added to $ipaddress/$subnet on interface $interface"
        echo ""
    else
        #Send errors from last command to log
        echo $lastcommand | predate >> $log_path
        echo ""
        echo "Delay failed. Please see $log_path for more information."
        echo ""
    fi
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

    	#Send errros from last command to log
    	echo $lastcommand | predate >> $log_path
        echo ""
        echo "Removal of delay on interface $interface failed. Please see $log_path for more information."
        echo ""
    fi
}


#Check for sudo..if no sudo, program will exit. If sudo is good, program will display main menu.
# root_checker(){
#     ROOT_UID="0"
#     if [ "$UID" -ne "$ROOT_UID" ] ; 
#         then
#             echo "You must have root privileges to run this script..."
#             echo "INVALID SUDO USER: `whoami`" | predate >> $log_path
#         else main_menu

#     fi #end if statement for root check/display main menu
# }


#Check if the --help flag is passed as an arguement
#Then check for sudo..if no sudo, program will exit. If sudo is good, program will display main menu.
help_checker(){
    if [[ $help == '--help' ]] 
        then
        #Display Help page
            echo ""
            echo "Run the program with no arguements to enter the main menu. Root privilege is required to add or remove delay."
            echo ""
            echo "Log file: $log_path"
            echo ""
        else
        #Check for sudo user
            if (( $(id -u) == 0 )); then
                main_menu
            else
                echo "This script runs commands which require root privileges"
                echo "INVALID SUDO USER: `whoami`" | predate >> $log_path
                exit 1
            fi
            # root_checker 
    fi #end if statement for help checker
}

help_checker
