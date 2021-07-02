#!/bin/bash
set -euxo pipefail
export EXTERNAL_IP="$(curl -s "https://ipinfo.io/json" | jq -r '.ip')" &&
echo Your VM external ip $EXTERNAL_IP ;

echo "Your VM external ip $EXTERNAL_IP it will be added to your values.yml file" &&
# Replace the EXTERNAL_IP variable on temp_values.yml in the repo rename and move it to the root directory for deployment
sed "s/EXTERNAL_IP/$EXTERNAL_IP/" temp_values.yml > tmp.yml && 
mv tmp.yml values.yml &&
mv -i values.yml $HOME && 
echo "We have updated your temp_values.yml file and renamed it, values.yml file with updated EXTERNAL_IP has been added to your root directory" ;
microk8s status --wait-ready && echo Kubectl step 4 success || echo Kubectl step 4 failure ; 
microk8s enable dns storage helm3 registry dashboard ingress && echo Kubectl step 5 success || echo Kubectl step 5 failure ; 
cd $HOME/.kube && echo Kubectl step 6 success || echo Kubectl step 6 failure ; 
microk8s config > config && echo Kubectl step 7 success || echo Kubectl step 7 failure ; 
echo "------------------Currently adding aliases to the .bashrc file..------------------" ;
sleep 2 &&
# We are adding need akiases to your .bashrc for ease of use and future commands
# echo "alias kubectl='microk8s.kubectl'" >> ~/.bashrc &&
# echo "alias helm='microk8s.helm3'" >> ~/.bashrc &&
# echo "alias k="kubectl --namespace my-namespace"" >> ~/.bashrc &&
# echo "alias h="helm --namespace my-namespace"" >> ~/.bashrc &&
# source ~/.bashrc && echo "------------------.bashrc has been updated------------------" || echo "------------------.bashrc update has failed------------------" ; Exit
cd $HOME &&
mkdir octant &&
cd octant &&
wget https://github.com/vmware-tanzu/octant/releases/download/v0.15.0/octant_0.15.0_Linux-64bit.deb &&
sudo dpkg -i octant_0.15.0_Linux-64bit.deb &&
echo "------------------Octant has been installed Open browser at http://$EXTERNAL_IP:8002------------------" || 
echo "------------------Octant install has failed------------------" ;
echo "------------------all required dependencies have been installed------------------"
sleep 4 &&
# We are now creating a kubectl namespace called my-namespace with command kubectl create namespace my-namespace
microk8s.kubectl create namespace my-namespace && 
echo "------------------kubectl namespace my-namespace has been created------------------" ||
echo "------------------kubectl namespace my-namespace failed to be created------------------" ;
# We now need to get the Rasa X helm repo https://github.com/RasaHQ/rasa-x-helm 
microk8s.helm3 repo add rasa-x https://rasahq.github.io/rasa-x-helm && 
microk8s.helm3 --namespace my-namespace install --values values.yml my-release rasa-x/rasa-x &&
echo "------------------helm --namespace my-namespace using values.yml has been installed" ||
echo "------------------helm --namespace my-namespace install Failed------------------" ; 
echo Lets verify you can access the endpoint from within the VM. You should get a result that looks like this  {"rasa":{"production":"1.10.3","worker":"0.0.0"},"rasa-x":"0.30.1",... You can also open in your browser here http://$EXTERNAL_IP:8000/api/version
microk8s.kubectl --namespace my-namespace get services && curl http://$EXTERNAL_IP/api/version &&
# read -e -p "Does this look correct? [Y/n] " YN
# [[ $YN == "y" || $YN == "Y" || $YN == "" ]] &&
# Starting Octant Listener at port :8002
# read -e -p "Would you like to start octant? [Y/n] " YN
# [[ $YN == "y" || $YN == "Y" || $YN == "" ]] &&
OCTANT_LISTENER_ADDR=0.0.0.0:8002 octant --disable-open-browser