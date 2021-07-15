#!/bin/bash

set -e

boolean() {
  case $1 in
    true) echo true ;;
    false) echo false ;;
    *) echo "Err: Unknown boolean value \"$1\"" 1>&2; exit 1 ;;
   esac
}


# Sets the debug mode
INSTALLER_DEBUG_MODE=$(boolean "${INSTALLER_DEBUG_MODE:-false}")

# Passwords and Tokens that will be updated on the values.yaml file
PASSWORD_SALT=${PASSWORD_SALT}
RASA_X_TOKEN=${RASA_X_TOKEN}
INITIAL_USER_PASSWORD=${INITIAL_USER_PASSWORD}
RASA_TOKEN=${RASA_TOKEN}
RABBITMQ_PASSWORD=${RABBITMQ_PASSWORD}
POSTGRES_PASSWORD=${POSTGRES_PASSWORD}
REDIS_PASSWORD=${REDIS_PASSWORD}

# Gets the ip of the current machine
EXTERNAL_IP=$(curl -s http://whatismyip.akamai.com/)

# The script can either use `wget` or `curl` to pull other scripts
DOWNLOADER=

if $INSTALLER_DEBUG_MODE
then
  set +x
  REDIRECT=/dev/stdout
else
  REDIRECT=/dev/null
fi

# Helper functions
echo_success() {
  echo -e "\e[1;32m${1}\e[0m"
}

echo_bold() {
  echo -e "\e[1m${1}\e[0m"
}

echo_error() {
  echo -e "\e[1;31m${1}\e[0m"
}

fatal() {
  echo "$@" >&2
  exit 1
}

seperator() {
  yes = | head -n$(($(tput cols) * 1)) | tr -d '\n'
  printf "\n \n \t \t \t $($1 "$2") \n \n"
  yes = | head -n$(($(tput cols) * 1)) | tr -d '\n'
  # use fatal to stop the script
  $3
}

app_installed () {
  # Return failure if it doesn't exist or is no executable
  which "$1" >/dev/null || return 1

  return 0
}

install_snapd() {
  app_installed snap && seperator echo_success "snapd is already installed skipping.." || 
  
  sudo apt-get install snapd -y >${REDIRECT} &&
  seperator echo_success "snapd has been installed" || seperator echo_error "snapd install failed" fatal 
}

install_snapd() {
  app_installed snap || 
  sudo apt-get install snapd -y >${REDIRECT} &&
  seperator echo_success "snapd has been installed" &&
  return 0 || 
  seperator echo_error "snapd install failed" fatal
  
  seperator echo_success "snapd is already installed skipping.." &&
  return 0
}

# install_snapd && 
# echo success

install_snapd &&
install_snapd &&
echo curt