#!/bin/bash

echo "Starting apt update installing snapd, git, docker, microk8s cluster and Octant manager on your server.." ; 
sleep 1.5 ;
sudo apt update ;
wget https://gist.githubusercontent.com/WCurtG/10273e1fca1c125a7e8bd103c9e9da62/raw/5738f12ad6453404929f48b46cbe0bcb0671cfde/values.yml ;
echo "We have added a values.yml file to you VM you need to update your info aftet this process has completed." ;
sleep 1.5 ;
sudo apt install snapd ;
sudo apt install git ;
sudo apt install docker.io docker-compose ;
sudo snap install microk8s --classic ;
sudo usermod -a -G microk8s $USER ;
sudo chown -f -R $USER ~/.kube ;
echo "Intial Setup completed. The VM will be restarted please reconnect and run rasax2.sh..." ;
sleep 3 ; sudo reboot