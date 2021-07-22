#! bin/bash 

set -e

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
    echo -e "\e[1;31m${1}\e[0m" >&2
    exit 1
}

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

line_break() {
    yes = | head -n$((${COLUMNS} * 1)) | tr -d '\n'
    echo -e "\n\n\n"
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