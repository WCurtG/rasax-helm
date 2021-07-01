#!/bin/bash

cd $HOME &&
wget https://gist.githubusercontent.com/WCurtG/10273e1fca1c125a7e8bd103c9e9da62/raw/f5d12bcc4200aa2f9a95782b9a6ac30e4effc603/values.yml &&
touch .env &&
echo "EXTERNAL_IPS="$(hostname -I | awk '{print $1}')"" >> .env &&
