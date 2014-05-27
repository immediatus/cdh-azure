#!/bin/bash

# Fix hostsnames on Manager and Workers
for i in cdh-manager cdh-worker-1 cdh-worker-2; do
  ssh dima@${i}.cloudapp.net "sudo sed -e '/127.0.0.1 localhost/a 127.0.1.1 '"${i}"' ' -i /etc/hosts"
done
