#!/bin/bash
################################################################################
# Title      : delete_vms.sh
# Author     : t.perelle@treeptik.fr
# Date       : 02/06/2018
################################################################################
# Description
#-------------------------------------------------------------------------------
# Version : 0.1
# training-k8s-provisionning
################################################################################

# load settings
source ./env.sh
source ./welcome.sh

welcome
# ./inventory.sh

# Delete VM for all students
echo "DROPLETS :"
doctl compute droplet list --format ID,Name | grep "${DO_PREFIX}-"
VM_IDS=$(doctl compute droplet list --format ID,Name | grep "${DO_PREFIX}-" | awk {'print $1'})
for vm in $VM_IDS; do
    echo "INFO - Suppression droplet : $vm"
    doctl compute droplet delete $vm -f
done

# Delete volumes
# echo ""
# echo "VOLUMES :"
# doctl compute volume list --format ID,Name | grep "${DO_PREFIX}-"
# VOL_IDS=$(doctl compute volume list --format ID,Name | grep "${DO_PREFIX}-" | awk {'print $1'})
# for vol in $VOL_IDS; do
#   echo "INFO - Suppression volume : $vol"
#   doctl compute volume delete -f $vol
# done

# ./inventory.sh
