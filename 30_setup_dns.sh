#!/bin/bash

source ./env

#Install Bind on master node
ssh -t $USERNAME@$MASTER.cloudapp.net " \
# Temporary replace public DNS
  sudo sed -e '/^nameserver/s/^/#/g' -i /etc/resolv.conf;
  sudo sed -e '/^#nameserver/a nameserver 8.8.8.8' -i /etc/resolv.conf; \

# Install Bind9
  sudo apt-get update
  sudo apt-get --yes install mc htop bind9

# Return back original DNS
  sudo sed -e '/nameserver 8.8.8.8/d' -i /etc/resolv.conf;
  sudo sed -e 's/^#nameserver/nameserver/' -i /etc/resolv.conf;
  sudo sed -e 's/^search .*/search internal/' -i /etc/resolv.conf;
"

# Copy Bind dns configs
scp resources/named.conf.local $USERNAME@cdh-manager.cloudapp.net:named.conf.local
scp resources/db.10 $USERNAME@cdh-manager.cloudapp.net:db.10
scp resources/db.internal $USERNAME@cdh-manager.cloudapp.net:db.internal
ssh -t $USERNAME@$MASTER.cloudapp.net "
  sudo mv named.conf.local /etc/bind/
  sudo mv db.10 /etc/bind/
  sudo mv db.internal /etc/bind/
  sudo service bind9 restart
"

# Fix search domain for worker nodes
for node in ${WORKERS[@]}; do
  ssh -t $USERNAME@${node}.cloudapp.net " \
    sudo sed -e 's/^search .*/search internal/' -i /etc/resolv.conf;
  "
done
