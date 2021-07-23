#!/bin/bash

# Exit immediately if one of the commands ends with a non-zero exit code
set -e

# Used in the installer debug mode
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

INSTALLER_DEBUG_MODE=$(boolean "${INSTALLER_DEBUG_MODE:-true}")

# Get the external IP address for VM
EXTERNAL_IP=$(curl -s http://whatismyip.akamai.com/)

# The script can either use `wget` or `curl` to pull other scripts
DOWNLOADER=

# Environment variables that can be set by the user before running the script (e.g. export VAR_TO_SET="var-value")
DISABLE_TELEMETRY=${DISABLE_TELEMETRY}
ENABLE_DUCKLING=${ENABLE_DUCKLING}
RASA_LOCATION=$PWD
NAME_SPACE=${NAME_SPACE}

# Passwords and Tokens that will be updated on the values.yaml file
PASSWORD_SALT=${PASSWORD_SALT}
RASA_X_TOKEN=${RASA_X_TOKEN}
INITIAL_USERNAME=${INITIAL_USERNAME}
INITIAL_USER_PASSWORD=${INITIAL_USER_PASSWORD}
RASA_TOKEN=${RASA_TOKEN}
RABBITMQ_PASSWORD=${RABBITMQ_PASSWORD}
POSTGRES_PASSWORD=${POSTGRES_PASSWORD}
REDIS_PASSWORD=${REDIS_PASSWORD}

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


download() {
    # [ $# -eq 1 ] || fatal 'download needs exactly 1 argument'
    url=$1

    [[ ${DOWNLOADER} == curl ]] && curl -sO "$1" || wget -q "$1" -O "${url##*/}" || fatal 'Download failed'
}

does_command_exist() {
    command -v "$1" >/dev/null
}

verify_downloader() {
    # Return failure if it doesn't exist or is no executable
    does_command_exist "$1" || return 1

    # Set verified executable as our downloader program and return success
    DOWNLOADER=$1
}

seperator echo_success ${COLUMNS}
seperator echo_success ${OSTYPE}


check_if_can_be_installed() {
    OS=$(uname | tr '[:upper:]' '[:lower:]')
    echo ${OS}
    [[ ${OS} == "linux" ]] && echo_success "Linux OS found script starting.. " || fatal "Running this script is only supported on Linux systems."

    verify_downloader curl || verify_downloader wget || fatal 'Cannot find curl or wget for downloading files'
    install_requirements || fatal 'Cannot install required packages'
}

shell_config_file() {
    if [[ "${SHELL}" =~ zsh ]]; then
        SHELL_CONFIG_FILE="${HOME}/.zshrc"
    elif [[ "${SHELL}" =~ bash ]]; then
        SHELL_CONFIG_FILE="${HOME}/.bashrc"
    fi
}

app_installed() {
    # Return failure if it doesn't exist or is no executable
    which "$1" >/dev/null || return 1

    return 0
}

install_snapd() {
    app_installed snap && seperator echo_success "snapd is already installed skipping.." ||
        {
            sudo apt-get -qq install snapd &&
                seperator echo_success "snapd has been installed" || seperator echo_error "snapd install failed" fatal
        }
}

install_docker() {
    app_installed docker && seperator echo_success "docker is already installed skipping.." ||
        {
            echo_bold "Installing docker ..."
            sudo apt-get -qq install docker.io docker-compose >/dev/null &&
                cd /etc/docker &&
                echo -e "{ \n  \t \"insecure-registries\" : [\"localhost:32000\"] \n}" >daemon.json &&
                seperator echo_success "docker has been installed" || seperator echo_error "docker install failed" fatal
        }
}

install_microk8s() {
    app_installed microk8s && seperator echo_success "microk8s is already installed skipping.." ||
        {
            sudo snap install microk8s --classic >/dev/null &&
                seperator echo_success "microk8s has been installed" || seperator echo_error "microk8s install failed" fatal
            sudo usermod -a -G microk8s "$USER"
            sudo chown -f -R "$USER" ~/.kube
            sudo su - "$USER" &
            seperator echo_success "re-entered the session for the group update" || seperator echo_error "re-enter failed" fatal
            microk8s status --wait-ready &&
                seperator echo_success "microk8s ready" || seperator echo_error "microk8s update status to ready has failed" fatal
            microk8s enable dns storage helm3 registry dashboard ingress >/dev/null &&
                seperator echo_success "microk8s add-ons ready" || seperator echo_error "microk8s add-ons set up has failed" fatal
            cd "$HOME"/.kube &&
                microk8s config >config &&
                seperator echo_success "microk8s configured" || seperator echo_error "microk8s not configured" fatal
        }
}

install_octant() {
    app_installed octant && seperator echo_success "octant is already installed skipping.." ||
        {
            cd "$HOME" &&
                mkdir -p octant &&
                cd octant &&
                wget https://github.com/vmware-tanzu/octant/releases/download/v0.21.0/octant_0.21.0_Linux-64bit.deb &&
                sudo dpkg -i octant_0.21.0_Linux-64bit.deb &&
                seperator echo_success "octant has been installed" || seperator echo_error "octant install failed" fatal
        }
}

# Make sure all the required packages are installed
install_requirements() {
    install_snapd &&
        install_docker &&
        install_microk8s &&
        install_octant &&
        namespace_question
}

namespace_exist() {
    # Return failure if it doesn't exist or is no executable
    microk8s.kubectl get ns "$1" >/dev/null || seperator echo_error "Namespace $1 does not exist. Exiting...." fatal

    upgrade_namespace
}

namespace_question() {
    seperator echo_success "** Current pods in all namespaces **" &&
        microk8s.kubectl get pods --all-namespaces &&
        NAME_SPACE=${NAME_SPACE:-my-namespace} &&
        namespace_exist "$NAME_SPACE"
}

upgrade_namespace() {
        cd "$HOME" &&
        microk8s.helm3 --namespace $NAME_SPACE upgrade --values values.yml my-release rasa-x/rasa-x &&
        provide_login_credentials ||
        seperator echo_error "namespace $NAME_SPACE has not been upgraded. Exiting.." fatal
}

run_loading_animation() {
    i=1
    sp="/-\|"
    while :; do
        sleep 0.1
        # Don't show spinner when we are debugging
        if ! $INSTALLER_DEBUG_MODE; then
            printf "\b%s" ${sp:i++%${#sp}:1}
        fi
    done
}

wait_till_deployment_finished() {
  # Run the loading animation in the background while are waiting for the deployment
  run_loading_animation &
  LOADING_ANIMATION_PID=$!
  # Kill loading animation when the install script is killed
  # Also mute error output in case the process was already killed before
  # shellcheck disable=SC2064
  trap "kill -9 ${LOADING_ANIMATION_PID} &> /dev/null || true" $(seq 1 15)
  # Wait for the deployment to be ready   
  my_ns_status=$(microk8s.kubectl get pods --field-selector=status.phase!=Succeeded,status.phase!=Running --namespace "${NAME_SPACE}")
  echo_success "Namespace "${NAME_SPACE}" is installing...."
  while [ ${#my_ns_status} -ne 0 ]; 
  do
    my_ns_status=$(microk8s.kubectl get pods --field-selector=status.phase!=Succeeded,status.phase!=Running --namespace "${NAME_SPACE}")
     sleep 1 
  done
  echo_success "Namespace "${NAME_SPACE}"status: Active" &&
  microk8s.kubectl get pods --namespace "${NAME_SPACE}"
  POD=$(microk8s.kubectl --namespace "${NAME_SPACE}" get pod -l app.kubernetes.io/component=rasa-x -o name)
  microk8s.kubectl --namespace "${NAME_SPACE}" exec "${POD}" -- /bin/bash -c 'curl -s localhost:$SELF_PORT/api/health | grep "\"status\":200"'
  # Stop the loading animation since the deployment is finished
  kill -9 ${LOADING_ANIMATION_PID}

  # Remove remnants of the spinner
  printf "\b"
}

provide_login_credentials() {
    wait_till_deployment_finished &&
    echo_success "Open in your browser here http://$EXTERNAL_IP:8000/api/version to check the api status and version \n \n Or run this command in your cli \n \n microk8s.kubectl --namespace "$NAME_SPACE" get services && curl http://$EXTERNAL_IP/api/version" &&
    microk8s.kubectl --namespace "$NAME_SPACE" get services &&

    # Determine the public IP address
    PUBLIC_IP=$(curl -s http://whatismyip.akamai.com/)
    LOGIN_URL="http://${EXTERNAL_IP}:8000/login?username=${INITIAL_USERNAME}&password=${INITIAL_USER_PASSWORD}"

    # Check if the URL is available over the public IP address
    STATUSCODE=$(curl --silent --connect-timeout 10 --output /dev/null --write-out "%{http_code}" "${LOGIN_URL}" || true)
    if test "$STATUSCODE" -ne 200; then
        # Determine the local IP address associated with a default gateway
        LOCAL_IP_ADDRESS=$(ip r g 8.8.8.8 | head -1 | awk '{print $7}')
        # Return the URL with the local IP address if the login webside is not available over the public address
        LOGIN_URL="http://${LOCAL_IP_ADDRESS}:8000/login?username=${INITIAL_USERNAME}&password=${INITIAL_USER_PASSWORD}"
    fi

    line_break
    echo_success "You can now access Rasa X on this URL: ${LOGIN_URL}"
    line_break
    add_alias
}

add_alias() {
    shell_config_file &&
        # [ "$(grep "^NAME_SPACE=" ~/.bash*)" ] || echo "NAME_SPACE=${NAME_SPACE}" >>"${SHELL_CONFIG_FILE}"
        [ "$(grep "^alias kubectl=" ~/.bash*)" ] || echo "alias kubectl='microk8s.kubectl'" >>"${SHELL_CONFIG_FILE}" &&
        [ "$(grep "^alias helm=" ~/.bash*)" ] || echo "alias helm='microk8s.helm3'" >>"${SHELL_CONFIG_FILE}" &&
        [ "$(grep "^alias k=" ~/.bash*)" ] || echo "alias k=\"kubectl --namespace ${NAME_SPACE}\"" >>"${SHELL_CONFIG_FILE}" &&
        [ "$(grep "^alias h=" ~/.bash*)" ] || echo "alias h=\"helm --namespace ${NAME_SPACE}\"" >>"${SHELL_CONFIG_FILE}" &&
        [ "$(grep "^VM_IP=" ~/.bash*)" ] || echo "VM_IP=${EXTERNAL_IP}" >>"${SHELL_CONFIG_FILE}" &&
        [ "$(grep "^alias api_v=" ~/.bash*)" ] || echo "alias api_v=\"curl http://${EXTERNAL_IP}:8000/api/version\"" >>"${SHELL_CONFIG_FILE}" &&
        seperator echo_success "Your ~/.bashrc file is up to date. aliases available: \n \n kubectl='microk8s.kubectl' \n \n helm='microk8s.helm3' \n \n k=\"kubectl --namespace ${NAME_SPACE}\" \n \n h=\"helm --namespace ${NAME_SPACE}\" \n \n api_v=\"curl http://${EXTERNAL_IP}:8000/api/version\" \n "
}

# This is the start of running code
check_if_can_be_installed
