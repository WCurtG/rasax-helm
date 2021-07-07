#!/bin/bash
set -e

boolean() {
  case $1 in
    true) echo true ;;
    false) echo false ;;
    *) echo "Err: Unknown boolean value \"$1\"" 1>&2; exit 1 ;;
   esac
}

# Helper functions
echo_success() {
  echo -e "\e[32m${1}\e[0m"
}

echo_bold() {
  echo -e "\e[1m${1}\e[0m"
}

fatal() {
  echo "$@" >&2
  exit 1
}

run_loading_animation() {
  i=1
  sp="/-\|"
  while :
  do
    sleep 0.1
    # Don't show spinner when we are debugging
    if ! $INSTALLER_DEBUG_MODE
    then
      printf "\b%s" ${sp:i++%${#sp}:1}
    fi
  done
}
# Replace the EXTERNAL_IP variable on temp_values.yml in the repo rename and move it to the root directory for deployment
# export EXTERNAL_IP="$(curl -s "https://ipinfo.io/json" | jq -r '.ip')" &&
export EXTERNAL_IP=$(curl -s http://whatismyip.akamai.com/) &&
echo Your VM external ip $EXTERNAL_IP &&
printf "\n# -------------------------------\n#       EXTERNAL_IP has been added to env variables \n# -------------------------------\n" ||
printf "\n# -------------------------------\n#       EXTERNAL_IP has failed to be added to env variables \n# -------------------------------\n" &&
printf "\n# Your VM external ip $EXTERNAL_IP it will be added to your values.yml file \n#" &&

rasax_pw () {
    echo your new password will be $YN && 
    export RASAX_PW=$YN &&
    printf "\n# -------------------------------\n#       New Password $TEST_PW saved \n# -------------------------------\n"
}

read -e -p "Do you want to set an new password? " YN
 [$YN == ""] && echo your password will remain the same || rasax_pw


sed "s/EXTERNAL_IP/$EXTERNAL_IP/;s/RASAX_PW/$RASAX_PW" temp_values.yml > tmp.yml && 
mv tmp.yml values.yml &&
mv -i values.yml $HOME && 
printf "\n# We have updated your temp_values.yml file and renamed it, values.yml file with updated EXTERNAL_IP has been added to your root directory \n" 
