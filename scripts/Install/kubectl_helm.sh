#!/bin/bash

# Exit immediately if one of the commands ends with a non-zero exit code
set -e

# Get the external IP address for VM
EXTERNAL_IP=$(curl -s http://whatismyip.akamai.com/)

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

# Causes an error on Github Actions because tput is not available
# $(tput cols) && columns=$(tput cols) || columns=100

TERM_COLS=${COLUMNS:-100}

seperator() {
    echo -e "\n\n\n"
    yes '=' | head -n$((${TERM_COLS} * 1)) | tr -d '\n'
    printf "\n \n \t \t \t $($1 "$2") \n \n"
    yes '=' | head -n$((${TERM_COLS} * 1)) | tr -d '\n'
    echo -e "\n\n\n"
    # use fatal to stop the script
    $3
}

line_break() {
    yes '=' | head -n$((${TERM_COLS} * 1)) | tr -d '\n'
    echo -e "\n\n\n"
}

update_vm() {
    sudo apt update -y &&
    sudo apt full-upgrade -y &&
    sudo apt autoremove -y &&
    sudo apt clean -y &&
    sudo apt autoclean -y &&
    check_if_can_be_installed
}

check_if_can_be_installed() {
    OS=$(uname | tr '[:upper:]' '[:lower:]')
    echo ${OS}
    [[ ${OS} == "linux" ]] && echo_success "Linux OS found script starting.. " || fatal "Running this script is only supported on Linux systems."

    install_dependencies || fatal 'Cannot install required packages'
}

# shell_config_file() {
#     if [[ "${SHELL}" =~ zsh ]]; then
#         SHELL_CONFIG_FILE="${HOME}/.zshrc"
#     elif [[ "${SHELL}" =~ bash ]]; then
#         SHELL_CONFIG_FILE="${HOME}/.bashrc"
#     fi
# }

app_installed() {
    # Return failure if it doesn't exist or is no executable
    which "$1" >/dev/null || return 1

    return 0
}

install_kubernetes() {
    # Install kubectl
    snap install kubectl --classic &&
    kubectl version --client &&
    sudo apt-get install -y kubelet kubeadm kubectl &&
    sudo apt-mark hold kubelet kubeadm kubectl
}

install_helm() {
    # Install helm
    snap install helm --classic
}

install_rasa_helm() {
    # Install Rasa Helm Charts https://github.com/RasaHQ/helm-charts
    helm repo add rasa https://helm.rasa.com
    helm repo update
}

install_dependencies() {
    # Check if the dependencies are already installed then install needed packages
    app_installed "kubectl" || install_kubernetes
    app_installed "helm" || install_helm
    install_rasa_helm &&
    namespace_question
}

namespace_exist() {
    # Return failure if it doesn't exist or is no executable
    kubectl get ns "$1" >/dev/null || return 1

    return 0
}

namespace_question() {
    seperator echo_success "** Current pods in all namespaces **" &&
        kubectl get pods --all-namespaces &&
        NAME_SPACE=${NAME_SPACE:-my-namespace} &&
        create_namespace
}

create_namespace() {
    namespace_exist "${NAME_SPACE}" &&
        seperator echo_success "kubectl namespace "${NAME_SPACE}"already exist" &&
        rebuild_namespace ||
        {
            echo_success Creating namespace ${NAME_SPACE}....
            cd "${HOME}" &&
                kubectl create namespace "${NAME_SPACE}" &&
                seperator echo_success "kubectl namespace "${NAME_SPACE}" has been created" ||
                seperator echo_error "kubectl namespace "${NAME_SPACE}" failed to be created." fatal
                cns_status=$(kubectl get pods --field-selector=status.phase!=Succeeded,status.phase!=Running --all-namespaces)
                echo_success "Namespace "${NAME_SPACE}"is installing...."
                while [ ${#cns_status} -ne 0 ]; 
                do
                   	cns_status=$(kubectl get pods --field-selector=status.phase!=Succeeded,status.phase!=Running --all-namespaces)
	                sleep 1 
                done
                echo_success "Namespace "${NAME_SPACE}"status: Active" &&
            password_question
        }
}

rebuild_namespace() {
    cd "${HOME}" && kubectl delete namespace "${NAME_SPACE}" &&
        kubectl create namespace "${NAME_SPACE}" &&
        seperator echo_success "kubectl namespace "${NAME_SPACE}" has been created" ||
        seperator echo_error "kubectl namespace "${NAME_SPACE}" failed to be created."
    password_question
}

password_question() {
    INITIAL_USERNAME=${INITIAL_USERNAME:-me} &&
    INITIAL_USER_PASSWORD=${INITIAL_USER_PASSWORD} &&
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
    cd "${RASA_LOCATION}/rasax-helm/scripts/Install" &&
        # Update the values.yaml file
        sed "s/PASSWORD_SALT/${PASSWORD_SALT}/ ; s/RASA_X_TOKEN/${RASA_X_TOKEN}/ ; s/INITIAL_USERNAME/${INITIAL_USERNAME}/ ;s/INITIAL_USER_PASSWORD/${INITIAL_USER_PASSWORD}/ ; s/RASA_TOKEN/${RASA_TOKEN}/ ; s/RABBITMQ_PASSWORD/${RABBITMQ_PASSWORD}/ ; s/POSTGRES_PASSWORD/${POSTGRES_PASSWORD}/ ; s/REDIS_PASSWORD/${REDIS_PASSWORD}/ ; s/EXTERNAL_IP/${EXTERNAL_IP}/ " temp_values.yml >tmp.yml &&
        mv tmp.yml values.yml &&
        mv -f values.yml "${HOME}" &&
        seperator echo_success "\n We have updated your temp_values.yml file and renamed it, values.yml file with updated \n \n \t EXTERNAL_IP : ${EXTERNAL_IP} \n \n \t INITIAL_USERNAME : ${INITIAL_USERNAME} \n \n \t INITIAL_USER_PASSWORD : ${INITIAL_USER_PASSWORD} \n \n Review the ${HOME}/values.yml file to find and update other advanced deployment information \n" &&
        deploy_rasax
}

deploy_rasax() {
    cd "${HOME}" &&
        # put in to fix the helm error https://github.com/helm/helm/issues/8776#issuecomment-742607909
        # chmod go-r /var/snap/microk8s/2262/credentials/client.config &&
        helm3 repo add rasa-x https://rasahq.github.io/rasa-x-helm >/dev/null &&
        helm3 --namespace "${NAME_SPACE}" install --values values.yml my-release rasa-x/rasa-x &&
        seperator echo_success "helm3 --namespace "${NAME_SPACE}" using values.yml has been installed" ||
        seperator echo_error "helm3 --namespace "${NAME_SPACE}" install Failed" fatal

        # Waiting for the deployment to be ready
        wait_till_deployment_finished &&
        echo_success "Open in your browser here http://${EXTERNAL_IP}:8000/api/version to check the api status and version \n \n Or run this command in your cli \n \n kubectl --namespace "${NAME_SPACE}" get services && curl http://${EXTERNAL_IP}/api/version" &&
        kubectl get pods --namespace "${NAME_SPACE}" &&
        # curl http://${EXTERNAL_IP}:8000/api/version &&
        provide_login_credentials
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
  my_ns_status=$(kubectl get pods --field-selector=status.phase!=Succeeded,status.phase!=Running --namespace "${NAME_SPACE}")
  echo_success "Namespace "${NAME_SPACE}" is installing...."
  while [ ${#my_ns_status} -ne 0 ]; 
  do
    my_ns_status=$(kubectl get pods --field-selector=status.phase!=Succeeded,status.phase!=Running --namespace "${NAME_SPACE}")
     sleep 1 
  done
  echo_success "Namespace "${NAME_SPACE}"status: Active" &&
  kubectl get pods --namespace "${NAME_SPACE}"
  POD=$(kubectl --namespace "${NAME_SPACE}" get pod -l app.kubernetes.io/component=rasa-x -o name)
  kubectl --namespace "${NAME_SPACE}" exec "${POD}" -- /bin/bash -c 'curl -s localhost:$SELF_PORT/api/health | grep "\"status\":200"'
  # Stop the loading animation since the deployment is finished
  kill -9 ${LOADING_ANIMATION_PID}

  # Remove remnants of the spinner
  printf "\b"
}

provide_login_credentials() {
    wait_till_deployment_finished &&
    echo_success "Open in your browser here http://$EXTERNAL_IP:8000/api/version to check the api status and version \n \n Or run this command in your cli \n \n kubectl --namespace "$NAME_SPACE" get services && curl http://$EXTERNAL_IP/api/version" &&
    kubectl --namespace "$NAME_SPACE" get services &&
    
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
}


# Start the installation
update_vm