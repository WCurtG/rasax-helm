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

does_command_exist() {
  command -v "$1" > /dev/null
}

password_question() {
  read -e -p "Please set your unique Rasa X password or leave blank and we will set a secure password for you and add it to your values.yml file in the root. " INITIAL_USER_PASSWORD
  INITIAL_USER_PASSWORD=${INITIAL_USER_PASSWORD:- } 
  generate_not_yet_specified_passwords
}

# This will be run when the user is propmted to create a password or let the system create one.
generate_not_yet_specified_passwords() {
  PASSWORD_SALT=$(get_specified_password_or_generate "${PASSWORD_SALT}") &&
  RASA_X_TOKEN=$(get_specified_password_or_generate "${RASA_X_TOKEN}") &&
  INITIAL_USER_PASSWORD=$(get_specified_password_or_generate "${INITIAL_USER_PASSWORD}") &&
  RASA_TOKEN=$(get_specified_password_or_generate "${RASA_TOKEN}") &&
  RABBITMQ_PASSWORD=$(get_specified_password_or_generate "${RABBITMQ_PASSWORD}") &&
  POSTGRES_PASSWORD=$(get_specified_password_or_generate "${POSTGRES_PASSWORD}") &&
  REDIS_PASSWORD=$(get_specified_password_or_generate "${REDIS_PASSWORD}") &&
  update_values
}

# Generates a random password when feed nothing.
get_specified_password_or_generate() {
  if [[ -z $1 ]]; then
    # shellcheck disable=SC2005
    echo "$(tr </dev/urandom -dc 'A-Za-z0-9' | head -c20)"
  else
    echo "$1"
  fi
}

update_values() {
  cd "$HOME"/rasax-helm-master &&
    # Update the values.yaml file
    sed "s/PASSWORD_SALT/${PASSWORD_SALT}/ ; s/RASA_X_TOKEN/${RASA_X_TOKEN}/ ; s/INITIAL_USER_PASSWORD/${INITIAL_USER_PASSWORD}/ ; s/RASA_TOKEN/${RASA_TOKEN}/ ; s/RABBITMQ_PASSWORD/${RABBITMQ_PASSWORD}/ ; s/POSTGRES_PASSWORD/${POSTGRES_PASSWORD}/ ; s/REDIS_PASSWORD/${REDIS_PASSWORD}/ ; s/EXTERNAL_IP/${EXTERNAL_IP}/ " temp_values.yml > tmp.yml && 
    mv tmp.yml values.yml &&
    mv -f values.yml "$HOME" &&
    ( seperator echo_success "\n We have updated your temp_values.yml file and renamed it, values.yml file with updated \n \n EXTERNAL_IP : ${EXTERNAL_IP} \n \n INITIAL_USER_PASSWORD : ${INITIAL_USER_PASSWORD} \n \n Review the "$HOME"/values.yml file to find and update other advanced deployment information \n" ) &&
    # deploy_helm
}