#!/bin/bash

# Exit immediately if one of the commands ends with a non-zero exit code
set -e

bold=$(tput bold)
blink=$(tput blink)

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
  echo -e "\e[1;31m${1}\e[0m" >&2
  exit 1
}

seperator() {
  echo -e "\n\n\n"
  yes = | head -n$(($(tput cols) * 1)) | tr -d '\n'
  center "$1"
  yes = | head -n$(($(tput cols) * 1)) | tr -d '\n'
  echo -e "\n\n\n"
  # use fatal to stop the script
  $3
}

center() {
  COLUMNS=`tput cols` export COLUMNS # Get screen width.
  "$1" | awk '
  { spaces = ('$COLUMNS' - length) / 2
    while (spaces-- > 0) printf (" ")
    printf
  }'
}     

seperator echo_success "this is centered"


echo "Curt"
# echo "${blink} curt"
# echo "${bold} Curt"

