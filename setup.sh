#!/bin/bash

echo "Ready to begin...";
chmod +x rasax1.sh rasax2.sh &&
echo "Shell files ready, install env ready to start." ||
echo "Shell files failed to become executable" &&
sleep 1.5 ;
x=0
while [ $x = 0 ]
do
    echo "Set up done would you like to run the next step? (y/n)"
    read answer

    case "$answer" in 
        y)
        echo "Great let's proceed! Running rasax1.sh";
        ./rasax1.sh
        x=1
        ;;
        n)
        echo "Exiting Rasa X setup.." && sleep 1 && break
        x=1
        ;;
        *)
        echo "Sorry that isn't an option choose y/n"
        sleep 1
        ;;
    esac
done