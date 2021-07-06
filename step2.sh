#!/bin/bash
set -euxo pipefail

microk8s status --wait-ready && 
echo "------------------Kubectl step 4 success------------------" || 
echo "------------------Kubectl step 4 failure------------------" &&
microk8s enable dns storage helm3 registry dashboard ingress && 
echo "------------------Kubectl step 5 success------------------" || 
echo "------------------Kubectl step 5 failure------------------" &&
cd $HOME/.kube && 
echo "------------------Kubectl step 6 success------------------" || 
echo "------------------Kubectl step 6 failure------------------" &&
microk8s config > config && 
echo "------------------Kubectl step 7 success------------------" || 
echo "------------------Kubectl step 7 failure------------------" &&
echo "------------------Currently adding aliases to the .bashrc file..------------------" &&
sleep 2 &&
sudo snap install kubectl --classic &&
echo "------------------kubectl has been installed------------------" ||
echo "------------------kubectl install failed------------------" ; 
sudo snap install helm --classic &&
echo "------------------helm has been installed------------------" ||
echo "------------------helm install failed------------------" ; 
echo "------------------Enabling add ons & Configuring kubectl...------------------"
sleep 2 &&
cd $HOME &&
mkdir octant &&
cd octant &&
wget https://github.com/vmware-tanzu/octant/releases/download/v0.15.0/octant_0.15.0_Linux-64bit.deb &&
sudo dpkg -i octant_0.15.0_Linux-64bit.deb &&
# We need to get the external IP inorder to add it to your values.yml
#EXTERNAL_IP="$(hostname -I | awk '{print $1}')"
export EXTERNAL_IP="$(curl -s "https://ipinfo.io/json" | jq -r '.ip')" &&
echo Your VM external ip $EXTERNAL_IP &&
printf "\n# -------------------------------\n#       EXTERNAL_IP has been added to env variables \n# -------------------------------\n" ||
printf "\n# -------------------------------\n#       EXTERNAL_IP has failed to be added to env variables \n# -------------------------------\n" &&
printf "\n# Your VM external ip $EXTERNAL_IP it will be added to your values.yml file \n#" &&
printf "\n# -------------------------------\n#       Octant has been installed Open browser at http://$EXTERNAL_IP:8002 \n# -------------------------------\n" ||
printf "\n# -------------------------------\n#       Octant install has failed \n# -------------------------------\n" &&
sleep 4 &&
# Replace the EXTERNAL_IP variable on temp_values.yml in the repo rename and move it to the root directory for deployment
cd rasax-helm-master &&
sed "s/EXTERNAL_IP/$EXTERNAL_IP/" temp_values.yml > tmp.yml && 
mv tmp.yml values.yml &&
mv -i values.yml $HOME && 
printf "\n# We have updated your temp_values.yml file and renamed it, values.yml file with updated EXTERNAL_IP has been added to your root directory \n" &&
# We are now creating a kubectl namespace called my-namespace with command kubectl create namespace my-namespace
# kubectl create namespace my-namespace &&
kubectl create namespace my-namespace &&
printf "\n# -------------------------------\n#       kubectl namespace my-namespace has been created \n# -------------------------------\n" ||
printf "\n# -------------------------------\n#       kubectl namespace my-namespace failed to be created \n# -------------------------------\n" &&
# We now need to get the Rasa X helm repo https://github.com/RasaHQ/rasa-x-helm 
# helm repo add rasa-x https://rasahq.github.io/rasa-x-helm && 
# helm --namespace my-namespace install --values values.yml my-release rasa-x/rasa-x &&
helm repo add rasa-x https://rasahq.github.io/rasa-x-helm && 
helm --namespace my-namespace install --values values.yml my-release rasa-x/rasa-x &&
printf "\n# -------------------------------\n#       helm --namespace my-namespace using values.yml has been installed \n# -------------------------------\n" ||
printf "\n# -------------------------------\n#       helm --namespace my-namespace install Failed \n# -------------------------------\n" &&
printf "Lets verify you can access the endpoint from within the VM. You should get a result that looks like this  {"rasa":{"production":"1.10.3","worker":"0.0.0"},"rasa-x":"0.30.1",... You can also open in your browser here http://$EXTERNAL_IP:8000/api/version
k get services && curl http://$EXTERNAL_IP/api/version" &&
read -e -p "Does this look correct? [Y/n] " YN
[[ $YN == "y" || $YN == "Y" || $YN == "" ]] &&
printf "The API endpoint looks correct, next we will start Octant it will be available at http://$EXTERNAL_IP:8002/#/"
# Starting Octant Listener at port :8002
read -e -p "Would you like to start octant? [Y/n] " YN
[[ $YN == "y" || $YN == "Y" || $YN == "" ]] &&
OCTANT_LISTENER_ADDR=0.0.0.0:8002 octant --disable-open-browser