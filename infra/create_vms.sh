#!/bin/bash
################################################################################
# Title      : create_vms.sh
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

################################################################################
# FUNCTIONS
################################################################################

# Check prerequisites
function check_prerequisites ()
{
  echo "INFO - Checking prerequisites..."
  export PR_ERROR=0
  for PREREQUISITE in $DIR_PREREQUISITES/*.sh; do
    source $PREREQUISITE
  done
  if [[ $PR_ERROR > 0 ]]; then
    echo "ERROR - $PR_ERROR prerequisites unsatisfied, see above"
    exit 50
  else
    echo "INFO - Prerequisites OK"
    echo ""
  fi
}

# Create volume
function create_volume () {
  vol_name=$1
  vol_size=$2
  vol_region=$3

  vol_id="doctl compute volume create $vol_name --size $vol_size \
  --region $vol_region --format 'ID' | awk 'NR==2'"

  eval "$vol_id"
}

# Create VM on DO
function create_vm () {
  vm_name=$1
  vm_region=$2
  vm_img=$3
  vm_size=$4
  vm_ssh_key=$5
  vm_tags=$6
  # vm_vol=$7

  doctl compute droplet create $vm_name --region $vm_region \
  --image $vm_img --size $vm_size --ssh-keys $vm_ssh_key \
  --tag-names $vm_tags >> /dev/null
}

################################################################################

welcome
check_prerequisites
STARTTIME=$(date +%s)

# Pour chaque participant, créer les VMs
for user in ${USERS[@]}; do
  echo "INFO - Create VMs for : ${user}"

  # Masters
  it=1
  while (( $it <= $NB_MASTER ))
  do
    DO_NAME="${DO_PREFIX}-${user}-master-${it}"
    echo "INFO - Create $DO_NAME"
    # volume_id=$(create_volume $DO_NAME $DO_VOL_SIZE $DO_REGION)
    create_vm $DO_NAME $DO_REGION $DO_IMG_CENTOS $DO_SIZE_MASTER $DO_SSH_KEY $DO_TAG
    let "it++"
  done

  # Nodes
  it=1
  while (( $it <= $NB_NODE ))
  do
    DO_NODE="${DO_PREFIX}-${user}-node-${it}"
    echo "INFO - Create $DO_NODE"
    # volume_id=$(create_volume $DO_NODE $DO_VOL_SIZE $DO_REGION)
    create_vm $DO_NODE $DO_REGION $DO_IMG_CENTOS $DO_SIZE_NODE $DO_SSH_KEY $DO_TAG
    let "it++"
  done
done

# Creation de l'inventaire
echo "INFO - Wait for VMs are ready..."
sleep 10s
./ansible.sh
./inventory.sh

echo "INFO - Private SSH key for centos account :"
echo ""
cat "$LOCAL_SSH_PRIVATE_KEY"
echo ""
chmod 600 $LOCAL_SSH_PRIVATE_KEY

ENDTIME=$(date +%s)
echo "INFO - Command done in $(($ENDTIME - $STARTTIME)) seconds"
exit 0
