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

branch="refs/head/restructer"

echo "${branch##*/}"
