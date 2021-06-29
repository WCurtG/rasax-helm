#!/bin/bash

echo "Currently adding aliases to the .bashrc file.." ;
sleep 2 ;
echo "alias kubectl='microk8s.kubectl'" >> ~/.bashrc &&
echo "alias helm='microk8s.helm3'" >> ~/.bashrc &&
echo "alias k="kubectl --namespace my-namespace"" >> ~/.bashrc &&
echo "alias h="helm --namespace my-namespace"" >> ~/.bashrc &&
source ~/.bashrc && echo ".bashrc has been updated" || echo ".bashrc update has failed" ;

cd $HOME &&
mkdir octant &&
cd octant &&
wget https://github.com/vmware-tanzu/octant/releases/download/v0.15.0/octant_0.15.0_Linux-64bit.deb &&
sudo dpkg -i octant_0.15.0_Linux-64bit.deb &&
OCTANT_LISTENER_ADDR=0.0.0.0:8002 octant --disable-open-browser && 
echo "Octant has been installed" || 
echo "Octant install has failed" ;

echo "Installing Helm and Kubectl" ;
sudo snap install kubectl --classic && kubectl version --client || 
echo "Kubectl install failed" ;
kubectl create namespace my-namespace && 
echo "kubectl namespace my-namespace has been created" ||
echo "kubectl namespace my-namespace failed to be created" ;
sudo snap install helm --classic || 
echo "Helm install failed" ;
helm repo add rasa-x https://rasahq.github.io/rasa-x-helm
helm --namespace my-namespace install --values values.yml my-release rasa-x/rasa-x



cip=$(hostname -I | awk '{print $1}')