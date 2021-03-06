#!/bin/bash 

set -e

# Set debug mode
boolean() {
  case $1 in
  true) echo true ;;
  false) echo false ;;
  *)
    echo "Err: Unknown boolean value \"$1\"" 1>&2
    exit 1
    ;;
  esac
}

INSTALLER_DEBUG_MODE=$(boolean "${INSTALLER_DEBUG_MODE:-false}")

# Installer debug vars
if $INSTALLER_DEBUG_MODE; then
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

# Causes an error on Github Actions because tput is not available
# $(tput cols) && columns=$(tput cols) || columns=100

seperator() {
  echo -e "\n\n\n"
  yes = | head -n$((${COLUMNS} * 1)) | tr -d '\n'
  printf "\n \n \t \t \t $($1 "$2") \n \n"
  yes = | head -n$((${COLUMNS} * 1)) | tr -d '\n'
  echo -e "\n\n\n"
  # use fatal to stop the script
  $3
}

# This is the easist way to add the Repo to your VM

update_vm() {
  sudo apt update -y && sudo apt full-upgrade -y && sudo apt autoremove -y && sudo apt clean -y && sudo apt autoclean -y &&
  download
}

app_installed() {
    # Return failure if both rasax-helm and rasax-helm-original exist in the same directory
    find $PWD/$1 && find $PWD/rasax-helm-original && 
    fatal "Too many existing versions found in current directory" ||
    find $PWD/$1 &&
    search_result="We renamed an existing version of rasax-helm to rasax-helm-original" &&
    seperator echo_success "replacing rasax-helm with rasax-helm-original in app_installed" &&
    # change the name of the existing version to rasax-helm-original
    mv -f $PWD/rasax-helm rasax-helm-original ||
    search_result="No existing rasax-helm found, we have added $PWD/rasax-helm" && return 0
}

download () {
  # check if the file exists in the current directory
  app_installed rasax-helm &&
  echo -e "\n\n\n $search_result \n\n\n" &&
  wget --quiet https://github.com/WCurtG/rasax-helm/archive/refs/heads/master.zip &&
  sudo apt-get install unzip -qq &&
  unzip -o -q $PWD/master.zip && 
  seperator echo_success "replacing rasax-helm with rasax-helm-original in download" &&
  # rename the downloaded version to rasax-helm
  mv -f $PWD/rasax-helm-master rasax-helm && 
  clean_up
}

clean_up () {
  # Remove the downloaded zip file
  find $PWD -type f -iname "master.zip" -mmin -2 -delete &&
  echo -e "\n\n\n"
  seperator echo_success "Cleaning up your download...."
  echo -e "\n\n\n"
  sleep 3
}
update_vm &&
seperator echo_success "master.zip has been cleaned from root and rasa-helm-master been added. You are currently in root/rasa-helm-master"
