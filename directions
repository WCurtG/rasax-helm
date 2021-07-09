# Install Rasa X on microk8s

Connect to your VM and issue these commands
$ sudo apt update
$ sudo apt install docker.io docker-compose
$ sudo snap install microk8s --classic

Join the microk8s group, to avoid use of sudo
$ sudo usermod -a -G microk8s $USER
$ sudo chown -f -R $USER ~/.kube
⇒ Exit the VM and reconnect

Enable add ons
$ microk8s enable dns storage helm3 registry dashboard ingress

Configure kubectl
$ cd $HOME/.kube
$ microk8s config > config
------------------------------
# Define aliases in ~/.bashrc

Add this to ~/.bashrc

alias kubectl='microk8s.kubectl'
alias helm='microk8s.helm3'

# set aliases for using kubectl in a namespace
alias k="kubectl --namespace my-namespace"

# set aliases for using helm  in a namespace
alias h="helm --namespace my-namespace"

Then, activate them with:
$ source ~/.bashrc
------------------------------
# Install octant on the VM

On the VM issue these commands to install Octant
$ cd $HOME
$ mkdir octant
$ cd octant
$ wget https://github.com/vmware-tanzu/octant/releases/download/v0.15.0/octant_0.15.0_Linux-64bit.deb
$ sudo dpkg -i octant_0.15.0_Linux-64bit.deb

Run octant in the background
$ OCTANT_LISTENER_ADDR=0.0.0.0:8002 octant --disable-open-browser &

Open browser at http://[VM INTERNET IP]:8002
------------------------------
Install Rasa X on the microk8s cluster on the VM
Create namespace
$ kubectl create namespace my-namespace

DEPLOY rasa-x with all defaults
$ helm repo add rasa-x https://rasahq.github.io/rasa-x-helm
$ helm --namespace my-namespace install my-release rasa-x/rasa-x

The Rasa X Helm Chart: https://github.com/RasaHQ/rasa-x-helm 
------------------------------
# Define “externalIPs” for the LoadBalancer service “my-release-rasa-x-nginx”

On the VM, create a file ‘values.yml’ with this content:

nginx:
  service:
    # connect LoadBalancer directly to VMs' internal IP
    # You get this value with: $ hostname -I
    externalIPs: [10.150.0.8]


Issue this command to upgrade the release:
$ helm --namespace my-namespace upgrade --values values.yml my-release rasa-x/rasa-x

Verify you can access the endpoint from within the VM
$ k get services
$ curl http://10.150.0.8:8000/api/version
{"rasa":{"production":"1.10.3","worker":"0.0.0"},"rasa-x":"0.30.1",...

Verify you can access the endpoint from your browser
http://35.236.231.7:8000/api/version
------------------------------
# Activity 1
1. Repeat all the steps of the demo
- Set up your VM with microk8s and aliases in ~/.bashrc
- Create the namespace “my-namespace”
- Install Rasa X with helm, using all defaults
- Define the externalIPs, using helm with a file “values.yml”


2. When time permits, explore the cluster with Octant:
Namespaces
Workloads, Services, ConfigMaps, Secrets & PVCs
# Edit the file 'values.yml'

Replace all <safe credential> with a different alphanumeric string.

# debugMode enables / disables the debug mode for Rasa and Rasa X
debugMode: true
nginx:
  service:
    # connect LoadBalancer directly to VMs' internal IP
    # You get this value with: $ hostname -I
    externalIPs: [10.150.0.8]
rasax:
    # initialUser is the user which is created upon the initial start of Rasa X
    initialUser:
        # password for the Rasa X user
        password: "workshop"
    # passwordSalt Rasa X uses to salt the user passwords
    passwordSalt: "<safe credential>"
    # token Rasa X accepts as authentication token from other Rasa services
    token: "<safe credential>"
    # jwtSecret which is used to sign the jwtTokens of the users
    jwtSecret: "<safe credential>"
    # tag refers to the Rasa X image tag
    tag: "0.32.1"
rasa:
    # token Rasa accepts as authentication token from other Rasa services
    token: "<safe credential>"
    # tag refers to the Rasa image tag
    tag: "1.10.12-full"
rabbitmq:
    # rabbitmq settings of the subchart
    rabbitmq:
        # password which is used for the authentication
        password: "<safe credential>"
global:
    # postgresql: global settings of the postgresql subchart
    postgresql:
        # postgresqlPassword is the password which is used when the postgresqlUsername equals "postgres"
        postgresqlPassword: "<safe credential>"
    # redis: global settings of the postgresql subchart
    redis:
        # password to use in case there no external secret was provided
        password: "<safe credential>"


------------------------------
# Reinstall Rasa X with Helm
Some of the credentials, like the initial users’ password, are not updated when using ‘helm upgrade’. 

For this reason, we will delete the namespace and re-install from scratch.

$ kubectl delete namespace my-namespace

$ kubectl create namespace my-namespace

$ helm repo add rasa-x https://rasahq.github.io/rasa-x-helm
$ helm --namespace my-namespace install --values values.yml my-release rasa-x/rasa-x
⇒ Monitor the installation progress in Octant

Once installation is finished, connect browser to:
http://<internet ip>:8000/api/version
http://<internet ip>:8000  
will redirect to login page
Login with the password you defined in the values.yml
------------------------------
# Activity 2a
Instructions

- Repeat all the steps of the demo
- Define values.yml with credentials
- Set initial users’ password to: “workshop”
- Delete the namespace “my-namespace”
- Create the namespace “my-namespace”
- Install Rasa X with helm

Check the installed version at: 
http://<internet ip>:8000/api/version

Login to Rasa X at
http://<internet ip>:8000
# Demo 3

Option 1: kubectl

Check the deployment status:
$ k get deployments
NAME                         READY   UP-TO-DATE   AVAILABLE 
my-release-rasa-production   1/1     1            1

Scale it up:
$ k scale deployment my-release-rasa-production --replicas=2

$ k get deployments
NAME                         READY   UP-TO-DATE   AVAILABLE
my-release-rasa-production   2/2     2            2

Scale it down:
$ k scale deployment my-release-rasa-production --replicas=1

$ k get deployments
NAME                         READY   UP-TO-DATE   AVAILABLE 
my-release-rasa-production   1/1     1            1

Tip: you can force a pod restart, by scaling the deployment down to 0 and then back up to 1
------------------------
Option 2: helm
Define replicaCount in the “values.yml”

# rasa: Settings common for all Rasa containers
rasa:
    versions:
       # rasaProduction is the container which serves the production environment
       rasaProduction:
           # replicaCount of the Rasa Production container
           replicaCount: 2


Then upgrade the release:
$ helm --namespace my-namespace upgrade --values values.yml my-release rasa-x/rasa-x
-------------------------
# Activity 3
Repeat all the steps of the demo
In Octant or with kubectl, check the number of pods for the rasa-production deployment.

Scale the number of pods up and down, while monitoring the number of pods.

At end of this activity, scale it to just 1 pod.

Bonus
Get a shell inside a rasa-production container and get the configurations from rasa-x
# Demo 4

Connect Integrated Version Control

1. Fork  https://github.com/RasaHQ/deployment-workshop-bot-1
2. Navigate to your forked copy
3. Copy the SSH URL from your GitHub repository
4. Connect Integrated Version Control in Rasa X
4.a. Specify the branch you want to use as master
4.b. Check “Require users to add changes to a new branch”
4.c. Do step 5, then click on “Verify connection”
5. Copy/paste the Deploy Key in your GitHub repository settings
5.a. Check “Allow write access”
------------------------------
# Train the Model and Talk to the Bot
In Octant, or using k logs <pod-name> --follow, view the logs of the rasa-worker pod
In Rasa X, click on the Train button, and wait until it is done.  (Do NOT yet tag it as the active model)
In Octant, or using k logs <pod-name> --follow, view the logs of the rasa-production pod, and notice that it is requesting a new model  every now at URL http://my-release-rasa-x-rasa-x:5002/api/projects/default/models/tags/production. 
my-release-rasa-x-rasa-x is the service endpoint of the rasa-x pod ! 
(Check it out with Octant Resource Viewer)
Keep the rasa-production logs screen open while in Rasa X, you make the trained model active.
You can see that once you tag the model as active in Rasa X, the rasa-production containers’ next request to the rasa-x service endpoint will return the new model, which the rasa-production container then unzips and stores inside the container.
Now, all is ready, and you can talk to the bot. → Keep the log of the rasa-production pod open.
--------------------------------

# Activity 4
Instructions

Repeat all the steps of the demo
Fork git repo & connect Rasa X to Git
While monitoring the logs of the rasa-worker container:
Train the model
While monitoring the logs of the rasa-production container:
Tag the trained model as active
Talk to the bot

Bonus
Use stern to monitor logs from multiple pods at once
$ wget https://github.com/wercker/stern/releases/download/1.11.0/stern_linux_amd64
$ chmod +x stern_linux_amd64
$ mv stern_linux_amd64 stern
$ ./stern -n my-namespace --tail 20 .
# Connect Rasa X to another github repo
We have another example bot, with a custom action. First connect rasa x: 
Fork  https://github.com/RasaHQ/deployment-workshop-bot-2
Navigate to your forked copy
Copy the SSH URL from your GitHub repository
Disconnect Git in Rasa X, and Connect to the newly forked bot-2:
Specify the branch you want to use as master
Check “Require users to add changes to a new branch”
Do step 5, then click on “Verify connection”
Copy/paste the Deploy Key in your GitHub repository settings
Check “Allow write access”
Train the bot
------------------------------
# Build the custom action server & push it into the microk8s build-in registry

Microk8s has a build-in container registry. You can build a docker image of the custom action server on the VM itself and push it into the docker registry of microk8s with these commands: 

# clone your forked repo to the VM
$ git clone https://github.com/[YOUR-GITHUB-NAME]/deployment-workshop-bot-2.git

$ cd deployment-workshop-2

$ sudo docker-compose build
...
Successfully built 4b3664846973
Successfully tagged localhost:32000/deployment-workshop-bot-2-action-server:0.0.1

$ sudo docker push localhost:32000/deployment-workshop-bot-2-action-server:0.0.1
------------------------------------
# Deploy the docker image of the custom action server
Add this to your  “values.yml” that you created before: 

# custom action server
app:
    # from microk8s build-in registry
    name: "localhost:32000/deployment-workshop-bot-2-action-server"
    tag: "0.0.1"

Install it with the command:
$ helm --namespace my-namespace upgrade --values values.yml my-release rasa-x/rasa-x
--------------------------------------
# Check that the rasa-production containers can reach the custom action server

The custom action server is not exposed outside the cluster, so we first get a terminal inside the cluster.
One option is to use Octant, and browse to the “Terminal” of a rasa-production pod.
Another option is to use this on the VM:
$ k get pods
$ k exec -it my-release-rasa-production-84fd95d977-5rsvh -- /bin/bash

Then, from the terminal inside the rasa-production container, issue these commands that use the k8s service my-release-rasa-x-app to reach the action server pods:
$ curl http://my-release-rasa-x-app:5055/health
{"status":"ok"}

$ curl http://my-release-rasa-x-app:5055/actions
[{"name":"action_hi"}]
--------------------------------------
# Test it out in Rasa X

Activate the model that you trained
Talk to your bot 
 
If the rasa-production container has not yet pulled the newly activated model from the rasa-x container, you are still talking to the previous model !
------------------------------------

# Activity 5
Repeat all the steps of the demo
Fork git repo
In Rasa X:
Connect Rasa X to Git
Train & activate the model
On the VM:
Clone your forked repo
Build the action server docker image
Push it into the microk8s container registry
Deploy your action server
In Rasa X: Talk to your bot, make sure it uses ‘action_hi’

Bonus
Scale the action server deployment to use 2 pods
# Demo 6

Managing Resources for Containers

You can specify how much of each resource a container requires / is allowed to use in the values.yml of the helm chart, eg. for the rasa-production container:

rasa:
 versions:
   rasaProduction:
     # resources which rasaProduction is required / allowed to use
     resources:
       requests:
         cpu: "2000m"
         memory: "2Gi"

Then, upgrade the installation with:
$ h upgrade --values values.yml my-release rasa-x/rasa-x
--------------------------------
#Activity 6

Instructions
Repeat all the steps of the demo
Update your “values.yml”
While monitoring the rasa-production pod in Octant, issue a “helm upgrade” command
Verify that the Resources in Octant now show updated memory and cpu.
Reset the cluster, by outcommenting the resources in the values.yml, and again issuing a “helm upgrade” command
Verify that the Resources in Octant show the memory and cpu as it was before the exercise.

# Activity 7

Repeat all the steps of the demo
As a guest tester, talk to your bot
In Rasa X:
Create training data from the conversations
Push the changes to your forked github repo
Confirm that Rasa X resets itself to the master branch
In Github:
View the changes in the new branch
Merge the branch to master
In Rasa X:
Wait until the change shows up
Train & activate the model
Verify the change is working
# Demo 8
In Rasa X, disconnect the Github repo

Add a github action to your forked github repo, in the location .github/workflows/ci_on_push.yml:

# See: https://help.github.com/en/actions/language-and-framework-guides/using-python-with-github-actions
name: CI on push
on:
 push:
   paths-ignore:
   - "README.md"
 
jobs:
 ci:
   name: CI job
   runs-on: ubuntu-latest
   steps:
   - uses: actions/checkout@v2
   - name: Set up Python 3.7
     uses: actions/setup-python@v2
     with:
       python-version: 3.7
   - name: Install dependencies
     run: |
       python -m pip install -U pip
       pip install -r requirements.txt
   - name: Test it all
     working-directory: ${{ github.workspace }}
     run: |
       rasa train --quiet
       rasa test --fail-on-prediction-errors


IMPORTANT: Now, in Rasa X, re-connect the Github repo before continuing.

Using an incognito window, As a guest tester, add another conversation

Let’s fix it in Rasa X, now using the NLU Inbox 

Push the change to your github repo

Then, when the checks all look ok:
In github, merge the branch to master
Note that this is another push, so the github action will run again.
Wait until the tests are completed.

In Rasa X
wait until it syncs with the changes to the master branch
train & activate the model
Note that you can automate this in your github action as well, see the earlier examples !
verify the change is working
-------------------------------------------
# Activity 8

Instructions

Repeat all the steps of the demo
Add the github action
Make in a change in Rasa X, and push it to github
Wait until the github action is completed
Merge the new branch to master
Wait until Rasa X has synced
Train the model & activate it
Verify the change works


