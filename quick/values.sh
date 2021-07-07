#!/bin/bash
set -euxo pipefail

# Replace the EXTERNAL_IP variable on temp_values.yml in the repo rename and move it to the root directory for deployment
# export EXTERNAL_IP="$(curl -s "https://ipinfo.io/json" | jq -r '.ip')" &&
export EXTERNAL_IP=$(curl -s http://whatismyip.akamai.com/) &&
echo Your VM external ip $EXTERNAL_IP &&
printf "\n# -------------------------------\n#       EXTERNAL_IP has been added to env variables \n# -------------------------------\n" ||
printf "\n# -------------------------------\n#       EXTERNAL_IP has failed to be added to env variables \n# -------------------------------\n" &&
printf "\n# Your VM external ip $EXTERNAL_IP it will be added to your values.yml file \n#" &&
sed "s/EXTERNAL_IP/$EXTERNAL_IP/" temp_values.yml > tmp.yml && 
mv tmp.yml values.yml &&
mv -i values.yml $HOME && 
printf "\n# We have updated your temp_values.yml file and renamed it, values.yml file with updated EXTERNAL_IP has been added to your root directory \n" &&