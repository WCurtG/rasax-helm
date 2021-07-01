#!/bin/bash

EXTERNAL_IP="$(hostname -I | awk '{print $1}')"



wget https://gist.githubusercontent.com/WCurtG/10273e1fca1c125a7e8bd103c9e9da62/raw/df604572a04301285217f7aaf1201a002634b745/temp_values.yml &&
sleep 3 &&
echo $EXTERNAL_IP &&
sed "s/EXTERNAL_IP/$EXTERNAL_IP/" temp_values.yml > tmp.yml && 
mv tmp.yml values.yml &&
mv -i values.yml $HOME

