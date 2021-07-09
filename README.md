# rasax-helm

The easy way to set up Rasa X on your VM server with shell.

## Installation

Download the repo and unzip to your VM for inspection

```bash
    curl -s https://raw.githubusercontent.com/WCurtG/rasax-helm/master/download | sudo bash
    cd rasax-helm-master
```

This simple scrpit automatically adds the repo to your Ubuntu 20.04 VM and deploys Rasa X. This is done with docker, microk8s, kubectl, helm and octant dashboard.

```bash
    curl -s https://raw.githubusercontent.com/WCurtG/rasax-helm/master/download | sudo bash
    cd rasax-helm-master && ./rasahelm
```

Upgrade your realse by running in a new shell

```bash
    curl -s https://raw.githubusercontent.com/WCurtG/rasax-helm/master/upgrade | sudo bash
```

Start Octant

```bash
    curl -s https://raw.githubusercontent.com/WCurtG/rasax-helm/master/octant | sudo bash
```

Install lens at ~/lens and start

```bash
    curl -s https://raw.githubusercontent.com/WCurtG/rasax-helm/master/lens | sudo bash
```
