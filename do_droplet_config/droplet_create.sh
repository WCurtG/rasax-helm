#!/bin/bash

set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# name of the node
NAME=${{ secrets.DIGITALOCEAN_DROPLET }}

SSH_KEY_NAME=${{ secrets.DIGITALOCEAN_KEYNAME }}
# node size
SIZE=8gb

# run speed to to select the best data center
datacent_selector () {
    better_ping=99999
    better_datacenter=''
    better_datacenter_name=''
    max_ping=${1:-1}

    datacenters="speedtest-lon1.digitalocean.com
    			speedtest-sfo1.digitalocean.com
    			speedtest-sfo2.digitalocean.com
    			speedtest-sfo3.digitalocean.com
    			speedtest-ams2.digitalocean.com
    			speedtest-ams3.digitalocean.com
    			speedtest-nyc1.digitalocean.com
    			speedtest-nyc2.digitalocean.com
    			speedtest-nyc3.digitalocean.com
    			speedtest-sgp1.digitalocean.com
    			speedtest-fra1.digitalocean.com
    			speedtest-tor1.digitalocean.com
    			speedtest-blr1.digitalocean.com"

    while read -r line; do
    	ping_avg=$(ping -c $max_ping $line | tail -n1 | cut -d'=' -f2 | cut -d'/' -f2)
    	if [ -z "$ping_avg" ]; then
    		echo "Ping ${bold}${line}${normal}: not available"
    		continue
    	fi
    	echo "Ping ${bold}${line}${normal}: $ping_avg ms"
    	if [ $(echo "$ping_avg < $better_ping" | bc) -eq 1 ]; then
    		better_ping=$ping_avg
    		better_datacenter=$line
    		better_datacenter_name=$(echo $line | cut -d'.' -f1 | cut -d'-' -f2)
    	fi
    done <<<"$datacenters"

    echo "Best datacenter: $better_datacenter_name ($better_datacenter)"
    REGION=${better_datacenter_name}
}

command_exists () {
    type "$1" &> /dev/null;
}

# check doctl exists
check_doctl () {
    if ! command_exists doctl; then
        echo "Please install doctl: brew install doctl"
        exit 1
    fi
}    

get_ssh_key () {
    SSH_ID=$(doctl compute ssh-key list | grep -i "${SSH_KEY_NAME}" | cut -d' ' -f1)
    SSH_KEY=$(doctl compute ssh-key get "${SSH_ID}" --format FingerPrint --no-header)
}    

 # create the droplet
droplet_create () {
    doctl compute droplet create "${NAME}" \
        --region "${REGION}" \
        --image ubuntu-20-10-x64 \
        --size "${SIZE}" \
        --ssh-keys "${SSH_KEY}" \
        --enable-ipv6 \
        --enable-monitoring \
        --wait
    # get the public ip of the node
    ID=$(doctl compute droplet list | grep "${NAME}" | cut -d' ' -f1)
    PUBLIC_IP=$(doctl compute droplet get "${ID}" --format PublicIPv4 --no-header)
    echo "- Waiting node to finish installation"
}

# Download repo to droplet
download_repo () {
    curl -s https://raw.githubusercontent.com/WCurtG/rasax-helm/master/download | sudo bash &&
    cd rasax-helm
}

#Run Code
datacent_selector &&
check_doctl &&
get_ssh_key &&
droplet_create &&
download_repo &&
echo "- Installation completed"