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


seperator() {
  echo -e "\n\n\n"
  yes '=' | head -n$((${COLUMNS} * 1)) | tr -d '\n'
  printf "\n \n \t \t \t $($1 "$2") \n \n"
  yes '=' | head -n$(($COLUMNS * 1)) | tr -d '\n'
  echo -e "\n\n\n"
  # use fatal to stop the script
  $3
}

# echo $COLUMNS

# seperator echo_success "testin"

FB_CALL=2
call_fb() {
  ((${FB_CALL}>5)) && echo "Get FB info update global vars" || echo "Don't get FB info"
}

echo ${FB_CALL}
call_fb