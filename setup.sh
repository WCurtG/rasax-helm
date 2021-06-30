#!/bin/bash

echo "Ready to begin...";
sleep 1;
x=0
while [ $x = 0 ]
do
    echo "------------------------------------------------------"
    echo "Set up done would you like to run the next step? (y/n)"
    echo "------------------------------------------------------"
    read answer

    case "$answer" in 
        y)
        echo "Great let's proceed!Starting apt update installing snapd, git, docker, microk8s cluster and Octant manager on your server.." && sleep 1 ;
        cd $HOME &&
        wget https://gist.githubusercontent.com/WCurtG/10273e1fca1c125a7e8bd103c9e9da62/raw/f5d12bcc4200aa2f9a95782b9a6ac30e4effc603/values.yml &&
        touch .env &&
        echo "EXTERNAL_IPS="$(hostname -I | awk '{print $1}')"" >> .env && 
        echo "------------------.env has been updated------------------" || 
        echo "------------------.env update has failed------------------" ;
        echo "------------------We have added a values.yml file to you VM you need to update your info after this process has completed.------------------" && sleep 1
        sudo apt install snapd &&
        echo "------------------------------------------------------" &&
        echo "snapd has been installed" &&
        echo "------------------------------------------------------" ||
        echo "------------------------------------------------------" &&
        echo "snapd install failed" &&
        echo "------------------------------------------------------" &&
        sudo apt install docker.io docker-compose &&
        echo "------------------------------------------------------" &&
        echo "docker has been installed" && 
        echo "------------------------------------------------------" ||
        echo "------------------------------------------------------" &&
        echo "docker install failed" &&
        echo "------------------------------------------------------" &&
        sudo snap install microk8s --classic &&
        echo "------------------------------------------------------" &&
        echo "microk8s has been installed" &&
        echo "------------------------------------------------------" ||
        echo "------------------------------------------------------"&&
        echo "microk8s install failed" &&
        echo "------------------------------------------------------" &&  
        sudo usermod -a -G microk8s $USER &&
        sudo chown -f -R $USER ~/.kube &&
        echo "------------------Intial Setup completed. Exit the VM by running the 'exit' command then reconnect and run rasax2.sh...------------------" ||
        echo "------------------Intial Setup failed------------------" 
        x=1
        ;;
        n)
        echo "------------------Exiting Rasa X setup..------------------" && sleep 1 && break
        x=1
        ;;
        *)
        echo "------------------Sorry that isn't an option choose y/n------------------" && sleep 1
        ;;
    esac
done