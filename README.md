# rasax-helm

The easy way to set up Rasa X on your VM server with shell. 


## Installation 

First you need to add the repo to your Ubuntu 20.04 VM server 

```bash 
    sudo apt update ;
    sudo apt install git &&
    git clone https://github.com/WCurtG/rasax-helm.git
```

This will set up you server for easy install and reboot. After your server reboots ssh in and move to rasax1.sh

```bash 
    cd rasax-helm
    sudo chmod -x setup.sh &&
    ./setup.sh
```

After reconnecting run 

```bash 
    ./rasax1.sh
```
