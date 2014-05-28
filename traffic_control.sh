#!/bin/bash
#v2.8- Code clean up


help=$1
log_path=/var/log/traffic_control_log.txt

#accept stdin and echo with date: stdin
predate(){
    while read line
    do
        echo $(date) ":" $line >>$log_path
    done
}

#Displays the main menu to prompt for delay addition/removal
main_menu(){
    echo "****************************************************************"
    echo "Select an option and press "enter":" 
    echo "1) Add delay to a network"
    echo "2) Remove delay from a network"
    echo "3) Display existing latency"
    echo "****************************************************************"
    echo "*Run script as ./traffic_control.sh --help for more information*" 
    echo "****************************************************************"
    read delay_answer

    case "$delay_answer" in
        1) add_delay
        ;;
        2) remove_delay
        ;;
        3) display_latency
        ;;
        *) echo""
           echo "Please enter a valid option..."
           main_menu  
        ;;
    esac
}

#Gathers the interface, IP address, subnet, and delay and adds the delay respectively
add_delay(){
    echo "Enter interface [ethX]..."
    read interface
    echo "Enter IP address or Network ID/subnet cidr [192.168.1.1/24]..."
    read ipaddress
    echo "Enter desired delay [ms] or delay range [ms] [ms] *With a space*..."
    read delay
    echo "Enter desired packet loss[%].."
    read loss
     
    tc qdisc list | grep netem >> /dev/null
    if [[ $? -eq 0 ]];
        then
            tc qdisc del dev $interface root 2>&1 | predate
            echo "Previous latency on interface $interface has been removed."
        else 
            echo "No previous latency on interface $interface detected"
    fi

    echo "************************************************************************************"
    echo "*Please wait, adding ${delay}ms delay to $ipaddress on interface $interface        *"
    echo "************************************************************************************"

    tc qdisc add dev $interface root handle 1: prio 2>&1 | predate

    tc filter add dev $interface parent 1:0 protocol ip pref 55 handle ::55 u32 match ip src ${ipaddress} flowid 2:1 2>&1 | predate
    
    if [[ $delay =~ [[:space:]] ]]
        then 
            first=$(echo $delay | cut -d \  -f 1)
            second=$(echo $delay | cut -d \  -f 2)
            
            lastcommand=$(tc qdisc add dev $interface parent 1:1 handle 2: netem delay ${first}ms ${second}ms loss ${loss} 2>&1)
                #Check if the previous command succeeded
                if [[ $? -eq 0 ]]; 
                then
                    echo ""
                    echo "Delay of ${first}ms ${second}ms with a loss of ${loss}% has successfully been added to $ipaddress on interface $interface"
                    echo ""
                else
                    #Send errors from last command to log
                    echo $lastcommand | predate
                    echo ""
                    echo "Delay failed. Please see $log_path for more information."
                    echo ""
                fi
        else
            lastcommand=$(tc qdisc add dev $interface parent 1:1 handle 2: netem delay ${delay}ms loss ${loss} 2>&1)
                #Check if the previous command succeeded
                if [[ $? -eq 0 ]]; 
                then
                    echo ""
                    echo "Delay of ${delay}ms with a loss of ${loss}% has successfully been added to $ipaddress on interface $interface"
                    echo ""
                else
                    #Send errors from last command to log
                    echo $lastcommand | predate
                    echo ""
                    echo "Delay failed. Please see $log_path for more information."
                    echo ""
                fi
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
    	echo $lastcommand | predate #>> $log_path
        echo ""
        echo "Removal of delay on interface $interface failed. Please see $log_path for more information."
        echo ""
    fi
}

#Display any existing latency on any interfaces
display_latency(){

    newcom=$(tc qdisc list 2>&1)

    if [[ $newcom == *netem* ]];
    then
        echo "***************************"
        echo "*Latency has been detected*"
        echo "***************************"
        tc qdisc list | grep netem
    else
        echo "No latency has been detected on your interfaces. Run 'tc qdisc list' for more information"
    fi
}

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
