#!/bin/bash -e

echo Deleting Virutal Machines
for vm in `azure vm list --json | jshon -a -e VMName -u`; do
  azure vm delete --quiet $vm
done

echo Deleting VM Disks
for i in `azure vm disk list --json | jshon -a -e Name -u`; do 
  azure vm disk delete  $i
done

echo Deleting Cloud Services
for i in `azure service list --json | jshon -a -e serviceName -u`; do 
  azure service delete --quiet $i
done

echo Deleting Virtual Networks
for i in `azure network vnet list --json | jshon -a -e Name -u`; do 
  azure network vnet delete --quiet $i
done

echo Deleting DNS Servers
for i in `azure network dnsserver list --json | jshon -a -e Name -u`; do 
  azure network dnsserver unregister --quiet --dns-id $i
done

echo Deleting Storage Accounts with Containers
for store in `azure storage account list --json | jshon -a -e name -u`; do
  key=`azure storage account keys list $store --json | jshon -e primaryKey -u`
  echo Found storage account \"$store\" with key \"$key\"
  for container in `azure storage container list -a $store -k $key --json | jshon -a -e name -u`; do
    echo Deleting Container $container
    azure storage container delete --quiet -a $store -k $key $container
  done

  echo Deleting Storage Account $store
  azure storage account delete --quiet $store
done

echo Deleting Affinity Groups
for i in `azure account affinity-group list --json | jshon -a -e name -u`; do
  azure account affinity-group delete --quiet $i
done
