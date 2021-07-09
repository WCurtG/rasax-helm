# rasax-helm

The easy way to set up Rasa X on your Ubuntu 20.04 VM server with Kubernetes management tools included.

## Download & Inspect

Download the repo and unzip to your VM for inspection

```bash
    curl -s https://raw.githubusercontent.com/WCurtG/rasax-helm/master/download | sudo bash
    cd rasax-helm-master
```

## Instalation

This simple scrpit automatically adds the repo to your Ubuntu 20.04 VM and deploys Rasa X. This is done with docker, microk8s, kubectl, helm and octant dashboard.

```bash
    curl -s https://raw.githubusercontent.com/WCurtG/rasax-helm/master/download | sudo bash
    cd rasax-helm-master && ./rasahelm
```

## Upgrading or Rebuilding your deployment

Upgrade your realse by running in a new shell

```bash
    curl -s https://raw.githubusercontent.com/WCurtG/rasax-helm/master/upgrade | sudo bash
```

Rebuild your namespce with the current values.yml

```bash
    curl -s https://raw.githubusercontent.com/WCurtG/rasax-helm/master/rebuild | sudo bash
```

## Kubernetes Management

Start Octant

```bash
    curl -s https://raw.githubusercontent.com/WCurtG/rasax-helm/master/octant | sudo bash
```

Install lens at ~/lens and start on your VM

```bash
    curl -s https://raw.githubusercontent.com/WCurtG/rasax-helm/master/lens | sudo bash
```
