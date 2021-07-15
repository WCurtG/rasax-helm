
# rasax-helm

The easy way to set up Rasa X on your Ubuntu 20.04 VM server with Kubernetes management tools included.

<!-- [![GitHub Super-Linter](https://github.com/WCurtG/rasax-helm/workflows/Lint%20Code%20Base/badge.svg)](https://github.com/marketplace/actions/super-linter) -->

## Download & Inspect

Download the repo and unzip to your VM for inspection

```bash
    curl -s https://raw.githubusercontent.com/WCurtG/rasax-helm/master/download | sudo bash &&
    cd rasax-helm
```

## Installation

This simple scrpit automatically adds the repo to your Ubuntu 20.04 VM and deploys Rasa X. This is done with docker, microk8s, kubectl, helm and octant dashboard.

```bash
    curl -s https://raw.githubusercontent.com/WCurtG/rasax-helm/master/download | sudo bash &&
    cd rasax-helm && ./rxhelm
```

## Upgrading or Rebuilding your deployment

Upgrade your realse by running in a new shell

```bash
    curl -s https://raw.githubusercontent.com/WCurtG/rasax-helm/master/upgrade | sudo bash
```

## Kubernetes Management

Start Octant

```bash
    curl -s https://raw.githubusercontent.com/WCurtG/rasax-helm/master/octant | sudo bash
```
