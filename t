#! bin/bash 

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

if $TERM == "" ; then
colums=40
else
colums=$(tput cols)
fi

seperator() {
    echo -e "\n\n\n"
    yes = | head -n$(($($colums) * 1)) | tr -d '\n'
    printf "\n \n \t \t \t $($1 "$2") \n \n"
    yes = | head -n$(($($colums) * 1)) | tr -d '\n'
    echo -e "\n\n\n"
    # use fatal to stop the script
    $3
}

# This is the easist way to add the Repo to your VM

app_installed() {
    # Return failure if it doesn't exist or is no executable
    which "$1" >/dev/null || retun 1

    return 0
}

download () {
  app_installed rasax-helm && 
  ( sudo apt update -q && sudo apt upgrade -qy && sudo apt autoremove -qy &&
  wget https://github.com/WCurtG/rasax-helm/archive/refs/heads/master.zip >${REDIRECT} &&
  sudo apt-get install unzip -y &&
  unzip master.zip >${REDIRECT} && 
  mv -f rasax-helm-master rasax-helm && 
  clean_up ) || fatal "rasax-helm is already installed"
}

clean_up () {
  find $PWD -type f -iname "master.zip" -mmin -2 -delete &&
  echo -e "\n\n\n"
  echo_success "Cleaning up your download...."
  echo -e "\n\n\n"
  sleep 3
}

app_installed rasax-helm
echo_success "Rasax-Helm is already installed"

# download &&
# seperator echo_success "master.zip has been cleaned from root and rasa-helm-master been added. You are currently in root/rasa-helm-master"

