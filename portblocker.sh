#!/bin/bash
#v1.0

help=$1

#Displays the main menu to prompt for port blocking & unblocking
main_menu(){
    echo "****************************************************************"
    echo "Select an option and press "enter":" 
    echo "1) Block GCM"
    echo "2) Unblock GCM"
	echo "3) Block specific ports"
	echo "4) Unblock specific ports"
    echo "5) Display blocked ports"
    echo "**********************************************************************"
    echo "*  Run script as ./portblocker.sh --help or -h for more information  *" 
    echo "**********************************************************************"
    read delay_answer
    echo "****************************************************************"
    case "$delay_answer" in
        1) block_gcm
        ;;
        2) unblock_gcm
        ;;
        3) block_specific
		;;
		4) unblock_specific
        ;;
        5) show_ports
		;;
        *) echo""
           echo "Please enter a valid option..."
           main_menu  
        ;;
    esac
}
#Block GCM only on ports 5228, 5229, & 5230
#Give the option to block GCM for all networks passing through the interface or specify a network
block_gcm(){
	echo "Select an option and press "enter":"
	echo "1) Block ALL networks"
	echo "2) Block specific network"
	read answer

	case "$answer" in
		1) iptables -t nat -A PREROUTING -p tcp -i br1 --dport 5228 -j DNAT --to-destination 192.168.199.3:3129
		;;
		2) 
			echo "Enter IP address or Network address"
			read ipaddress
			iptables -t nat -A PREROUTING -i br1 -p tcp -s ${ipaddress} --dport 5228 -j REDIRECT --to 9999
		;;
		*) block_gcm
		;;
	esac
}
#Unblock GCM only on ports 5228, 5229, & 5230
#Give the option to unblock GCM for all networks passing through the interface or specify a network
unblock_gcm(){
	echo "Select an option and press "enter":"
	echo "1) Unblock ALL networks"
	echo "2) Unblock specific network"
	read answer

	case "$answer" in
		1) 
		   iptables -t nat -D PREROUTING -p tcp -i br1 --dport 5228 -j DNAT --to-destination 192.168.199.3:3129
		;;
		2) 	
			echo "Enter IP address or Network address"
			read ipaddress
			iptables -t nat -D PREROUTING -i br1 -p tcp -s ${ipaddress} --dport 5228 -j REDIRECT --to 9999
		;;
		*) unblock_gcm
		;;
	esac

}
#Block ports by specific port number
#Give the option to block a specific port on all networks passing through the interface or to specify a network
block_specific(){
	echo "Select an option and press "enter":"
	echo "1) Block specific ports on ALL networks"
	echo "2) Block specific ports on a specific network"
	read answer

	case "$answer" in
		1) 
			echo "Enter port number or port range i.e.- [5228] or [5228:5230]"
			read port_number
			iptables -t nat -A PREROUTING -p tcp -i br1 --dport ${port_number} -j DNAT --to-destination 192.168.199.3:3129
		;;
		2) 
			echo "Enter IP address or Network address"
			read ipaddress
			echo "Enter port number or port range i.e.- [5228] or [5228:5230]"
			read port_number
			iptables -t nat -A PREROUTING -i br1 -p tcp -s ${ipaddress} --dport ${port_number} -j REDIRECT --to 9999
		;;
		*) block_specific
		;;
	esac
	
}
#Unblock ports by specific port number
#Give the option to unblock a specific port on all networks passing through the interface or to specify a network
unblock_specific(){
	echo "Select an option and press "enter":"
	echo "1) Unblock specific ports on ALL networks"
	echo "2) Unblock specific ports on a specific network"
	read answer

	case "$answer" in
		1) 
			echo "Enter port number or port range i.e.- [5228] or [5228:5230]"
			read port_number
			iptables -t nat -D PREROUTING -p tcp -i br1 --dport ${port_number} -j DNAT --to-destination 192.168.199.3:3129
		;;
		2) 
			echo "Enter IP address or Network address"
			read ipaddress
			echo "Enter port number or port range i.e.- [5228] or [5228:5230]"
			read port_number
			iptables -t nat -D PREROUTING -i br1 -p tcp -s ${ipaddress} --dport ${port_number} -j REDIRECT --to 9999
		;;
		*) unblock_specific
		;;
	esac

}
#Show a list of current iptable rules implemented
show_ports(){

	iptables -t nat -L

}
#Check for sudo user
sudo_checker(){

	if (( $(id -u) == 0 )); then
				clear
                main_menu
            else
                echo "This script runs commands which require root privileges"
                echo "INVALID SUDO USER: `whoami`"
                exit 1
    fi
}

#Check if the --help flag is passed as an arguement
#Then check for sudo..if no sudo, program will exit. If sudo is good, program will display main menu.
help_checker(){
    if [[ $help == '--help' || $help == '-h' ]] 
        then
        #Display Help page
        	echo ""
            echo "**********************************************************************************************************************"
            echo "* Run the script with no arguements to enter the main menu. Root privilege is required to block or unblock any ports *"
            echo "**********************************************************************************************************************"
        else
        	sudo_checker        
    fi #end if statement for help checker
}

help_checker