# rasax-helm

The easy way to set up Rasa X on your VM server with shell.

## Installation

Download the repo and unzip to your VM

```bash
curl -s https://raw.githubusercontent.com/WCurtG/rasax-helm/master/download | sudo bash
```

First you need to add the repo to your Ubuntu 20.04 VM server and run start.sh

```bash
    curl -s https://raw.githubusercontent.com/WCurtG/rasax-helm/master/download | sudo bash
    cd rasax-helm-master && ./start.sh
```

After reconnecting run, this will install Octant, Kubectl and create a Rasa X dployment based on your values.yml file

```bash
    . ~/.bashrc
    ./step2.sh
```
