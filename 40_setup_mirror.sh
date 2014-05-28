#!/bin/bash -e

source ./env

#Install Apache2 on master node
ssh -t $USERNAME@$MASTER.cloudapp.net "sudo apt-get --yes install apache2"

# Attach Blob disk with Cloudera archive
