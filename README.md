# rasax-helm

The easy way to set up Rasa X on your VM server with shell. 


## Installation 

First you need to add the repo to your Ubuntu 20.04 VM server and run the first setup.sh file and propmt you to eexit 


```bash 
    sudo apt update && sudo apt upgrade &&
    wget https://github.com/WCurtG/rasax-helm/archive/refs/heads/master.zip &&
    sudo apt install unzip && unzip master.zip &&
    cd rasax-helm && ./setup.sh
```

After reconnecting run, this will install Octant, Kubectl and create a Rasa X dployment based on your values.yml file 

```bash 
    cd rasax-helm ;
    ./setup2.sh
```
