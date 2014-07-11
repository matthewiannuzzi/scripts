#!/bin/bash
img=$1
iso=$2


option_checker(){
	if [[ -z $img ]]
		then
			echo "Please run the command with the --help flag for more information."
			exit 1
		else
			help_checker
	fi
}
help_checker(){
    if [[ $img == '--help' ]] 
        then
        #Display Help page
            echo ""
            echo "*************************** WARNING ******************************"
            echo "************         Use at your own risk         ****************"
            echo "******************************************************************"
            echo ""
            echo "If you are converting a .iso file to .img, run as: "
            echo "./bootable_drive.sh [/path/to/img/file] [/path/to/iso/file] "
            echo ""
            echo "If your .iso file is already converted, run as: "
            echo "./bootable_drive [/path/to/img/file] "
            echo ""
        else
            select_disk
    fi
}

select_disk(){

	diskutil list
	echo "*********************************************"
	echo "Enter a disk number"
	read disk_no
	disk_no=disk$disk_no
	echo "*********************************************"
	echo "Would you like to format this disk? (y/n)"
	read answer
	if [[ $answer == 'y' ]]
		then	
			diskutil eraseDisk Free Space $disk_no
			image_prep
		else
			image_prep
	fi
}

image_prep(){
	echo "Is your file already in .img format? (y/n)"
	read answer
	if [[ $answer == 'y' ]]
		then
			burn_disk
		else
			hdiutil convert -format UDRW -o $img $iso

			if [[ $? -eq 0 ]]
				then
					echo "Converted successfully"
					mv ${img}.dmg $img
					burn_disk
				else
					echo "An error occurred with converting $iso_file"
					image_prep
			fi
	fi
}

burn_disk(){
	echo "Are you sure you want to procced with burning? (y/n)"
	read answer
	if [[ $answer == 'y' ]]
		then
			sudo dd if=$img of=/dev/$disk_no bs=1m
		else
			burn_disk
	fi
}

option_checker

