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
EXTERNAL_IP=$(curl -s http://whatismyip.akamai.com/)

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
  echo -e "\n\n\n"
  yes = | head -n$(($(tput cols) * 1)) | tr -d '\n'
  printf "\n \n $($1 "$2") \n \n"
  yes = | head -n$(($(tput cols) * 1)) | tr -d '\n'
  echo -e "\n\n\n"
  # use fatal to stop the script
  $3
}

seperator() {
  yes '=' | head -n$(($(tput cols) * 1)) | tr -d '\n'
  printf "\n \n $($1 "$2") \n \n"
  yes '=' | head -n$(($(tput cols) * 1)) | tr -d '\n'
}


start_octant() {
  read -e -p "Would you like to start octant? [Y/n] " YN
  [[ $YN == "y" || $YN == "Y" || $YN == "" ]] &&
    {seperator echo_success "Octant is starting. You can access it in a browser at http://${EXTERNAL_IP}:8002/#/" &&
    OCTANT_LISTENER_ADDR=0.0.0.0:8002 octant --disable-open-browser &&
    seperator echo_error "Octant failed to start." fatal } ||
    seperator echo_bold "Octant will not be started." fatal
}

start_octant