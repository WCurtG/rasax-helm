#!/bin/bash


echo "- Destroying the droplet"
# delete the droplets
doctl compute droplet delete -f ${{ secrets.DIGITALOCEAN_DROPLET }}