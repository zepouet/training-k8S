#!/bin/bash
################################################################################
# Title      : inventory.sh
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

# ------------------------
# CREATE TRAINER INVENTORY
# ------------------------
echo "INFO - Create trainer summary..."
# rm old summary file
SUMMARY_FILE="summary.txt"
rm -f $SUMMARY_FILE

echo " " >> $SUMMARY_FILE
echo "#######################################################" >> $SUMMARY_FILE
echo "# Cloud : DigitalOcean" >> $SUMMARY_FILE
echo "# Droplet prefix : $DO_PREFIX" >> $SUMMARY_FILE
echo "#######################################################" >> $SUMMARY_FILE
echo " " >> $SUMMARY_FILE

# Environment summary
echo "# Machines virtuelles :" >> $SUMMARY_FILE
doctl compute droplet list --format "ID,Name,PublicIPv4,Tags" | grep $DO_TAG >> $SUMMARY_FILE
echo " " >> $SUMMARY_FILE

# Print summary
cat $SUMMARY_FILE
