#!/bin/bash

DROPLET=${{ secrets.DIGITALOCEAN_DROPLET }}

echo "- Destroying the droplet"
# delete the droplets
doctl compute droplet delete -f "${DROPLET}"