#! /bin/bash

#This script was coded for a linux project.
#Free to distribute or re-use. Under GNU 2.0 license.

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
#built-in rm function can be still called as /bin/rm
#Recycle Bin Directory Config File = $HOME/.safe-rm-config/.bindir
#du -sch $(cat $HOME/.safe-rm-config/.bindir) | sort -hr  --> This function analyzes the Recycle Bin.
#/bin/rm $(cat $HOME/.safe-rm-config/.bindir)/* -r --> This function should clear the Recycle Bin.
configFolder=$HOME/.safe-rm-config
initializerLine='function rm(){ if (( $# == 0 )); then $HOME/.safe-rm-config/safe-rm.sh; elif [[ $1 = "--clear" ]]; then /bin/rm -r $(cat $HOME/.safe-rm-config/.bindir)/* 2> /dev/null; elif [[ $1 = "-a" ]]; then du -sch $(cat $HOME/.safe-rm-config/.bindir) | sort -hr; else mv $* "$(cat $HOME/.safe-rm-config/.bindir)" 2> /dev/null; fi; }'
bashRc=~/.bashrc

function endSession()
{
    clear
    source ~/.bashrc #so new settings will take effect.
    exec bash
}

function setBashRc()
{
    echo "" >> $bashRc #Create a new line in bashrc.
    echo "$initializerLine" >> $bashRc #Add the "rm overrider" function.
    cp $0 $configFolder/safe-rm.sh
    dialog --title 'Finalizing' --msgbox "Installed safe-rm and safe-rm is running. For help, run rm without any arguments." 10 30
    endSession
}

function setBinDirectory()
{
    freeSpace=$(df -h / | awk 'FNR == 2 {print $4}')
    dialog --title "Configuration" --yesno "You have $freeSpace free space in your disk. Would you like safe-rm to be installed on it's default path ($HOME/SafeBin)? y/n" 8 60
    dialogAnswer=$?

    if (( $dialogAnswer ==  0 )) #0 means a yes
    then
        if [ ! -d "$configFolder" ]; then
            mkdir $configFolder       
        fi  
        echo "$HOME/SafeBin" > "$configFolder/.bindir"
    elif (( $dialogAnswer == 1 )) #1 means a no
    then
        if [ ! -d "$configFolder" ]; then
            mkdir $configFolder       
        fi 
        dialog --title "Configuration" \
        --inputbox "Please specify a location for Recycle Bin (Enter a full path, beginning with "$HOME")" 8 60 2> "$configFolder/.bindir"     
    fi
    answer=$(cat "$configFolder/.bindir")
    if (( ${#answer} == 0)) #Checking the length of given path, if zero then ask for a valid path.
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
        dialog --title "Info" --yesno "Recycle Bin Directory: $(cat $HOME/.safe-rm-config/.bindir)\nTo analyze recycle bin: rm -a\nTo clear recycle bin: rm --clear\nStatus: Running.\nWould you like to stop the service? y/n" 10 60
        answer=$?
        if (( $answer ==  0 )) #0 means a yes
        then
            sed -i "/function rm()/d" $bashRc
            dialog --title 'Info' --msgbox "Safe remove service has been stopped. Ending this terminal session." 8 30
            endSession
        else
            dialog --title 'Info' --msgbox "Ending this terminal session." 6 30
            endSession
        fi
    else
        dialog --title "Info" --yesno "Safe remove service is not installed on this system. Would you like to run the service? y/n" 6 60
        answer=$?
        if (( $answer ==  0 )) #0 means a yes
        then
            setBinDirectory
        else
            dialog --title 'Info' --msgbox "Ending this terminal session." 6 30
            endSession
        fi
    fi

}


checkIfInstalled


