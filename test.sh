#!/bin/bash - 
#===============================================================================
#
#          FILE: test.sh
# 
#         USAGE: ./test.sh 
# 
#   DESCRIPTION: 
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: YOUR NAME (), 
#  ORGANIZATION: 
#       CREATED: 01/01/2018 08:44
#      REVISION:  ---
#===============================================================================

# Strict mode
set -euo pipefail
IFS=$'\n\t'

# Constants
HOSTNAMEREGEX="^[0-9a-zA-Z][0-9a-zA-Z-_]{0,100}[0-9a-zA-Z]"
RECIPIENTS="" # TODO
SELFROOT=`dirname $0`
TESTOBJECTS="test-objects.txt"


while read value
do
  if [[ $HOST =~ $HOSTNAMEREGEX ]] ; then
    # If test object passes regex, it should pass the tests
    EXPECTED=true
  else
    # If test object fails regex, it should fail the tests
    EXPECTED=true
  fi
  # Test virtual host configuration file creation
  # Test virtual host configuration file disable
  # Test virtual host configuration file enable
  # Test virtual host configuration file removal
done < $SELFROOT/$TESTOBJECTS

# Report
