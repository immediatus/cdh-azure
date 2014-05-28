#!/bin/bash -e

source ./env

ALL_NODES=( $MASTER ${WORKERS[@]} )
# Fix hostsnames on Manager and Workers
for i in ${ALL_NODES[@]}; do
  ssh $USERNAME@${i}.cloudapp.net "sudo sed -e '/127.0.0.1 localhost/a 127.0.1.1 '"${i}"' ' -i /etc/hosts"
done
