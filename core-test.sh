#! /bin/bash

#This script was coded for a linux project.
#Free to distribute or use. Under GNU license.

#How does it work?
#When you run the script for the first time, it is going to check if it's already installed on the system.
#If not, then it's going to ask if it should be installed.
#It checks how much space left in the current disk and by default it's going to place the bin to'
#/SafeBin in root directory.
#If you want to set the bin directory to another place, you will be asked so.
#In order to install this service, you need to run this script with root privilieges.

#Whats the use?
#It prevents the risky 'rm' built-in method to remove files instantly.
#So you have a safer way to use rm.


#Hard-coded configs to keep in mind.
#Recycle Bin Directory Config File = .bindir

initializerLine="function rm(){ echo 'Safe removing file(s).';}"
bashRc=~/.bashrc

function setBashRc()
{
    echo "" >> $bashRc
    echo "$initializerLine" >> $bashRc
    dialog --title 'Finalizing' --msgbox "Installed safe-rm and safe-rm is running." 6 30
}

function setBinDirectory()
{
    freeSpace=$(df -h / | awk 'FNR == 2 {print $4}')
    dialog --title "Configuration" --yesno "You have $freeSpace free space in your disk. Would you like safe-rm to be installed on it's default path? ($HOME/SafeBin)." 12 60
    dialogAnswer=$?

    if (( $dialogAnswer ==  0 )) #0 means a yes
    then
        echo "$HOME/SafeBin" > .bindir
    elif (( $dialogAnswer == 1 )) #1 means a no
    then        
        dialog --title "Configuration" \
        --inputbox "Please specify a location for Recycle Bin " 8 60 2> .bindir
    fi

    answer=$(cat .bindir)
    if (( ${#answer} == 0))
    then
        dialog --title 'Configuration' --msgbox "You should enter a valid directory!" 6 30
        setBinDirectory
    else
        dialog --title 'Configuration' --msgbox "You have set the directory as $answer" 6 30
        mkdir -p $answer
        setBashRc #Since folder initialization is done, now we can set .bashrc content and start safe-rm.
    fi

}



function checkIfInstalled(){

    if grep -Fxq "$initializerLine" $bashRc
    then
        echo "Safe remove service is running. Would you like to stop the service? y/n"

        read answer
    if [[ $answer == "y" ]]
    then
        sed -i "/$initializerLine/d" $bashRc
    fi

    else
        echo "Safe remove service is not installed on this system. Would you like to run the service? y/n"

        read answer

    if [[ $answer == "y" ]] 
    then
        setBinDirectory
    else
        echo "Terminating."
    fi

    fi

}

function start()
{
    checkIfInstalled
}

start
