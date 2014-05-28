#!/bin/bash -e

source ./env

# Install Cloudera Manager Server on master node
ssh -t $USERNAME@$MASTER.cloudapp.net "
  sudo wget -P /etc/apt/sources.list.d/ http://${MASTER}/cm5/ubuntu/precise/amd64/cm/cloudera.list;
  wget -qO - http://${MASTER}/cm5/ubuntu/precise/amd64/cm/archive.key | sudo apt-key add - ;
  sudo apt-get update;
  sudo apt-get -q -y install oracle-j2sdk1.7;

  sudo apt-get -q -y install cloudera-manager-server-db-2;
  sudo service cloudera-scm-server-db start;
 
  sudo apt-get -q -y install cloudera-manager-daemons cloudera-manager-server;
  sudo service cloudera-scm-server start;

  sudo apt-get -q -y install cloudera-manager-agent;
  sudo service cloudera-scm-agent start;
"

# Copy private key to the Master be able to login to Workers
scp ~/.ssh/id_rsa ${USERNAME}@${MASTER}.cloudapp.net:.ssh/

# Install Cloudera Agents on Workers
for node in ${WORKERS[@]}; do
  ssh -t $USERNAME@${node}.cloudapp.net "
    sudo wget -P /etc/apt/sources.list.d/ http://${MASTER}/cm5/ubuntu/precise/amd64/cm/cloudera.list;
    wget -qO - http://${MASTER}/cm5/ubuntu/precise/amd64/cm/archive.key | sudo apt-key add - ;
    sudo apt-get update;
    sudo apt-get -q -y install oracle-j2sdk1.7;

    sudo apt-get -q -y install cloudera-manager-daemons cloudera-manager-agent;
    sudo sed -i 's/server_host=localhost/server_host=${MASTER}/' /etc/cloudera-scm-agent/config.ini;
    sudo service cloudera-scm-agent start;
"
done

# Open Cloudera Manager port on Master
azure vm endpoint create -n cloudera-scm ${MASTER} 7180

echo "Wait for SCM start and start configuring in browser http://${MASTER}.cloudapp.net:7180"
