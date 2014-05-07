#!/bin/bash

#Author: Matt Iannuzzi
#v2.2


#Initial option select, format disk or proceed
echo $'Select an option and press "enter":\n1) Format USB \n2) USB Already Formatted, proceed'
read initial_answer

case "$initial_answer" in
#CASE 1***FORMAT DRIVE
    1) 
#Display a lists of available disks
        diskutil list
        echo "Enter diskX: "
        read disk_number
#Verify user wants to format disk
        echo "Are you sure you want to completely format disk$disk_number? (y/n)"
        read are_you_sure
#Case statement for format	
	case "$are_you_sure" in
		y) 
#Format the desired disk
			diskutil eraseDisk Free Space disk$disk_number
		;;
#Exit if user says NO		
		n)
			echo "Good choice, this will entirely format your selected drive. Please run the script again and ensure you select the correct disk to format."
            exit 0
		;;
		
		*)	echo "You have not entered a valid selection, program will now terminate."
            exit 0
		esac
#Prompt user if they want to convert ISO or PROCEED        
        echo $'**********************************************\nSelect an option and press "enter":\n1) Convert an ISO to an IMG\n2) File has already been converted, proceed'
        read convert_answer
#Case statement for conversion, then for imaging        
        case "$convert_answer" in
        1)
#Convert ISO to IMG using HDIUTIL
            hdiutil convert -format UDRW -o $1 $2
            echo "Would you now like to burn your IMG to disk$disk_number? (y/n)"
            read burn_answer
                case "$burn_answer" in
                y)                
                    echo $'********************************\n*Hal will now copy .img to USB...\n********************************'
                    sudo dd if=$1.dmg of=/dev/rdisk$disk_number bs=1m
                ;;
                n) echo "You have not entered a valid selection, program will now terminate."
                   exit 0
                ;;
                *) echo "You have not entered a valid selection, program will now terminate."
                   exit 0
                esac
        ;; 
        
        2) 
            echo "Would you now like to burn your IMG to disk$disk_number? (y/n)"
            read burn_answer
                case "$burn_answer" in
                y)                
                    echo $'********************************\n*Hal will now copy .img to USB...\n********************************'
                    sudo dd if=$1 of=/dev/rdisk$disk_number bs=1m
                ;;
                n) echo "You have not entered a valid selection, program will now terminate."
                   exit 0
                ;;
                *) echo "You have not entered a valid selection, program will now terminate."
                   exit 0
                esac
        ;;
        *) echo "You have not entered a valid selection, program will now terminate."
           exit 0
		
        esac
    ;;

    2)
        #Display a lists of available disks
        diskutil list
        echo "Enter diskX to make bootable: "
        read disk_number
        
        echo $'**********************************************\nSelect an option and press "enter":\n1) Convert an ISO to an IMG\n2) File has already been converted, proceed'
        read convert_answer
        
        case "$convert_answer" in
        1)
            hdiutil convert -format UDRW -o $1 $2
            echo "Would you now like to burn your IMG to disk$disk_number? (y/n)"
            read burn_answer
                case "$burn_answer" in
                y)                
                    echo $'********************************\n*Hal will now copy .img to USB...\n********************************'
                    sudo dd if=$1.dmg of=/dev/rdisk$disk_number bs=1m
                ;;
                n) echo "You have not entered a valid selection, program will now terminate."
                   exit 0
                ;;
                *) echo "You have not entered a valid selection, program will now terminate."
                   exit 0
                esac
        ;;
        
        2) 
            echo "Would you now like to burn your IMG to disk$disk_number? (y/n)"
            read burn_answer
                case "$burn_answer" in
                y)                
                    echo $'********************************\n*Hal will now copy .img to USB...\n********************************'
                    sudo dd if=$1 of=/dev/rdisk$disk_number bs=1m
                ;;
                n) echo "You have not entered a valid selection, program will now terminate."
                   exit 0
                ;;
                *) echo "You have not entered a valid selection, program will now terminate."
                   exit 0
                esac
        ;;
        *) echo "You have not entered a valid selection, program will now terminate."
           exit 0
		esac
        
    ;;
esac
exit 0
