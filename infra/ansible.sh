#!/bin/bash
################################################################################
# Title      : ansible.sh
# Author     : t.perelle@treeptik.fr
# Date       : 09/06/2018
################################################################################
# Description
#-------------------------------------------------------------------------------
# Version : 0.1
# training-k8s-provisionning
################################################################################

# load settings
source ./env.sh

# ------------------------
# CREATE ANSIBLE INVENTORY
# ------------------------
echo "Create trainer ansible inventory..."
# Refresh Ansible inventory
rm -f $HOSTS_FILE

# Global part of the ansible inventory
vms="doctl compute droplet list --format "Name,PublicIPv4,Tags" | grep $DO_PREFIX"
eval "$vms" | awk -F " " '{ print $1 " ansible_host=" $2 }' >> $HOSTS_FILE
echo "" >> $HOSTS_FILE

# User part of the ansible inventory
for user in ${USERS[@]}; do
  echo "[${user}]" >> $HOSTS_FILE
  doctl compute droplet list --format "Name,PublicIPv4,Tags" | grep $DO_PREFIX | grep ${user} | awk {'print $1'} >> $HOSTS_FILE
  echo "" >> $HOSTS_FILE
done

echo "[master]" >> $HOSTS_FILE
doctl compute droplet list --format "Name,PublicIPv4,Tags" | grep $DO_PREFIX | grep master | awk {'print $1'} >> $HOSTS_FILE
echo "" >> $HOSTS_FILE
echo "[node]" >> $HOSTS_FILE
doctl compute droplet list --format "Name,PublicIPv4,Tags" | grep $DO_PREFIX | grep node | awk {'print $1'} >> $HOSTS_FILE
echo "" >> $HOSTS_FILE
echo "[all:vars]" >> $HOSTS_FILE
echo "ansible_ssh_private_key_file=$LOCAL_SSH_PRIVATE_KEY" >> $HOSTS_FILE
echo "" >> $HOSTS_FILE

# --------------------------
# CREATE ANSIBLE CONFIG FILE
# --------------------------
echo "Create trainer ansible config file..."
# Refresh Ansible configuration
rm -f $ANSIBLE_CONFIG_FILE
echo "[defaults]" >> $ANSIBLE_CONFIG_FILE
echo "inventory = hosts" >> $ANSIBLE_CONFIG_FILE
echo "host_key_checking = False" >> $ANSIBLE_CONFIG_FILE
echo "retry_files_enabled = False" >> $ANSIBLE_CONFIG_FILE
echo "gather_facts = True" >> $ANSIBLE_CONFIG_FILE
echo "forks = 100" >> $ANSIBLE_CONFIG_FILE

# ----------------------------
# CREATE KUBESPRAY INVENTORIES
# ----------------------------
# Refresh directory
rm -f $DIR_KUBESPRAY_INVENTORIES/kubespray_inventory*

# Create kubespray inventory for each user
for user in ${USERS[@]}; do
  echo "Create kubespray inventory for $user..."
  user_inventory="$DIR_KUBESPRAY_INVENTORIES/kubespray_inventory_${user}"
  masters="doctl compute droplet list --format "Name" | grep $DO_PREFIX | grep $user | grep master"
  nodes="doctl compute droplet list --format "Name" | grep $DO_PREFIX | grep $user | grep node"

  if [ ! -f "$user_inventory" ]; then
    touch $user_inventory
#    echo "$user_inventory"
  fi

  # node list
  vms="doctl compute droplet list --format "Name,PublicIPv4,Tags" | grep $DO_PREFIX | grep $user"
  eval "$vms" | awk -F " " '{ print $1 " ansible_host=" $2 }' >> $user_inventory
  echo "" >> $user_inventory

  echo "[kube-master]" >> $user_inventory
  eval "$masters" >> $user_inventory
  echo "" >> $user_inventory
  echo "[kube-node]" >> $user_inventory
  eval "$nodes" >> $user_inventory
  echo "" >> $user_inventory
  echo "[etcd:children]" >> $user_inventory
  echo "kube-master" >> $user_inventory
  echo "" >> $user_inventory
  echo "[kube-ingress:children]" >> $user_inventory
  echo "kube-node" >> $user_inventory
  echo "" >> $user_inventory
  echo "[k8s-cluster:children]" >> $user_inventory
  echo "kube-master" >> $user_inventory
  echo "kube-node" >> $user_inventory
  echo "kube-ingress" >> $user_inventory
done
