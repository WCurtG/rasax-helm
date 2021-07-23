
# rasax-helm

The easy way to set up Rasa X on your Ubuntu 20.04 VM server with Kubernetes management tools included.

<!-- [![GitHub Super-Linter](https://github.com/WCurtG/rasax-helm/workflows/Lint%20Code%20Base/badge.svg)](https://github.com/marketplace/actions/super-linter) -->

## Download & Inspect

Download the repo and unzip to your VM for inspection

```bash
    curl -s https://raw.githubusercontent.com/WCurtG/rasax-helm/master/Install/download.sh | sudo bash &&
    cd rasax-helm
```

## Installation

This simple scrpit automatically adds the repo to your Ubuntu 20.04 VM and deploys Rasa X. This is done with docker, microk8s, kubectl, helm and octant dashboard.

```bash
    curl -s https://raw.githubusercontent.com/WCurtG/rasax-helm/master/Install/download.sh | sudo bash && rasax-helm/Install/./rxhelm.sh
```

You can also use the Github Actions to deploy to Digital Ocean

![Download the Repo](https://github.com/WCurtG/rasax-helm/actions/workflows/download.yml/badge.svg)

![Download and Deploy to DO droplet](https://github.com/WCurtG/rasax-helm/actions/workflows/deploy_rasax_new.yml/badge.svg)

![Upgrade Your Rasa X Deployment](https://github.com/WCurtG/rasax-helm/actions/workflows/upgrade_current_rasax.yml/badge.svg)

## Upgrading or Rebuilding your deployment

Upgrade your realse by running in a new shell

```bash
    curl -s https://raw.githubusercontent.com/WCurtG/rasax-helm/master/Upgrade/upgrade.sh | sudo bash
```

## Kubernetes Management

Start Octant

```bash
    curl -s https://raw.githubusercontent.com/WCurtG/rasax-helm/master/Install/octant.sh | sudo bash
```

