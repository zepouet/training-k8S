#!/bin/bash
################################################################################
# Title      : doctl.sh - Check prerequisite Doctl
# Author     : t.perelle@treeptik.fr
# Date       : 10/06/2018
################################################################################
# Description
#-------------------------------------------------------------------------------
# Version : 0.1
#
################################################################################

DOCTL_VERSION=$(doctl version | awk 'NR==1 {print $1,$3}')

if [ $(echo "$DOCTL_VERSION" | cut -d' ' -f1) == "doctl" ]; then
  echo "INFO - Doctl is present : $DOCTL_VERSION"
else
  echo "WARN - Doctl is not present and is needed"
  let "PR_ERROR++"
fi
