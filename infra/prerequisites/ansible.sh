#!/bin/bash
################################################################################
# Title      : ansible.sh - Check prerequisite Ansible
# Author     : t.perelle@treeptik.fr
# Date       : 05/11/2017
################################################################################
# Description
#-------------------------------------------------------------------------------
# Version : 0.1
#
################################################################################

ANSIBLE_VERSION=$(ansible --version | awk 'NR==1 {print $1,$2}')

if [ $(echo "$ANSIBLE_VERSION" | cut -d' ' -f1) == "ansible" ]; then
  echo "INFO - Ansible is present : $ANSIBLE_VERSION"
else
  echo "WARN - Ansible is not present and is needed"
  let "PR_ERROR++"
fi
