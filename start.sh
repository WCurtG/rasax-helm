#!/bin/bash
set -euxo pipefail


# We are adding need akiases to your .bashrc for ease of use and future commands
echo "alias kubectl='microk8s.kubectl'" >> ~/.bashrc &&
echo "alias helm='microk8s.helm3'" >> ~/.bashrc &&
echo "alias k="kubectl --namespace my-namespace"" >> ~/.bashrc &&
echo "alias h="helm --namespace my-namespace"" >> ~/.bashrc &&
printf "\n# -------------------------------\n#       .bashrc has been updated \n# -------------------------------\n" ||
printf "\n# -------------------------------\n#       .bashrc update has failed \n# -------------------------------\n" &&


# Intall the required dependencies 
# We were using jq to parse the json from https://ipinfo.io/json to get the EXTERNAL_IP now using http://whatismyip.akamai.com/ and its not needed 
# sudo apt-get install jq &&
# printf "\n# -------------------------------\n#       jq has been installed \n# -------------------------------\n" ||
# printf "\n# -------------------------------\n#       jq install failed \n# -------------------------------\n" &&
sudo apt install snapd &&
printf "\n# -------------------------------\n#       snapd has been installed \n# -------------------------------\n" ||
printf "\n# -------------------------------\n#       snapd install failed \n# -------------------------------\n" &&
sudo apt install docker.io docker-compose &&
printf "\n# -------------------------------\n#       docker has been installed \n# -------------------------------\n" ||
printf "\n# -------------------------------\n#       docker install failed \n# -------------------------------\n" &&
sudo snap install microk8s --classic &&
printf "\n# -------------------------------\n#       microk8s has been installed \n# -------------------------------\n" ||
printf "\n# -------------------------------\n#       microk8s install failed \n# -------------------------------\n" &&
# Replace the EXTERNAL_IP variable on temp_values.yml in the repo rename and move it to the root directory for deployment
# export EXTERNAL_IP="$(curl -s "https://ipinfo.io/json" | jq -r '.ip')" &&
export EXTERNAL_IP=$(curl -s http://whatismyip.akamai.com/) &&
echo Your VM external ip $EXTERNAL_IP &&
printf "\n# -------------------------------\n#       EXTERNAL_IP has been added to env variables \n# -------------------------------\n" ||
printf "\n# -------------------------------\n#       EXTERNAL_IP has failed to be added to env variables \n# -------------------------------\n" &&
printf "\n# Your VM external ip $EXTERNAL_IP it will be added to your values.yml file \n#" &&
sed "s/EXTERNAL_IP/$EXTERNAL_IP/" temp_values.yml > tmp.yml && 
mv tmp.yml values.yml &&
mv -i values.yml $HOME && 
printf "\n# We have updated your temp_values.yml file and renamed it, values.yml file with updated EXTERNAL_IP has been added to your root directory \n" &&
# Join the microk8s group, to avoid use of sudo
sudo usermod -a -G microk8s $USER 
sudo chown -f -R $USER ~/.kube &&
sudo su - $USER 


