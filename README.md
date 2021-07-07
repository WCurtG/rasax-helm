# rasax-helm

The easy way to set up Rasa X on your VM server with shell. 


## Installation 

To just clone the repo and unzip to your VM

```bash 
curl -s https://raw.githubusercontent.com/WCurtG/rasax-helm/master/quick/rasax-quick.sh | sudo bash
```

First you need to add the repo to your Ubuntu 20.04 VM server and run start.sh


```bash 
    sudo apt update && 
    sudo apt upgrade &&
    wget https://github.com/WCurtG/rasax-helm/archive/refs/heads/master.zip &&
    sudo apt install unzip &&
    unzip master.zip &&
    cd rasax-helm-master && ./start.sh
```

After reconnecting run, this will install Octant, Kubectl and create a Rasa X dployment based on your values.yml file 

```bash 
    . ~/.bashrc
    ./step2.sh
```
