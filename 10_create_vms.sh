#!/bin/bash

# Check Azure CLI tools are installed
type azure >/dev/null 2>&1 || {
  echo >&2 "\
  Azure CLI Tools should be installed and configured.
  See http://azure.microsoft.com/en-us/documentation/articles/xplat-cli"
  exit 1
}         

USERNAME='dima'
MASTER=cdh-manager
WORKERS=( cdh-worker-1 cdh-worker-2 )
UBUNTU_VM_IMAGE='b39f27a8b8c64d52b05eac6a62ebad85__Ubuntu-12_04_4-LTS-amd64-server-20140514-en-us-30GB'

# Create affinity group (alias for closest datacenter)
azure account affinity-group create \
  --location "West Europe" \
  --label cdh-eu-west \
  cdh-eu-west

# Create virtual network and DNS
azure network dnsserver register -i cdh-dns 10.0.0.4
azure network vnet create \
  --address-space 10.0.0.0 \
  --cidr 8 \
  --subnet-name cdh-subnet \
  --subnet-start-ip 10.0.0.0 \
  --subnet-cidr 24 \
  --affinity-group cdh-eu-west \
  --dns-server-id cdh-dns \
  cdh-vnet

# Create storage account
azure account storage create --affinity-group cdh-eu-west cdheuwest

# Create small VM for DNS server and CDH manager
azure vm create \
  --virtual-network-name cdh-vnet \
  --subnet-names cdh-subnet \
  --vm-size small \
  --affinity-group cdh-eu-west \
  --ssh 22 \
  --ssh-cert ~/.ssh/id_rsa.pem \
  --no-ssh-password \
  $MASTER \
  $UBUNTU_VM_IMAGE \
  $USERNAME

# Create a bunch of worker nodes
for worker in ${WORKERS[@]}; do
  azure vm create \
  --virtual-network-name cdh-vnet \
  --subnet-names cdh-subnet \
  --vm-size medium \
  --affinity-group cdh-eu-west \
  --ssh 22 \
  --ssh-cert ~/.ssh/id_rsa.pem \
  --no-ssh-password \
  $worker \
  $UBUNTU_VM_IMAGE \
  $USERNAME

done
