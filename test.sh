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
#  REQUIREMENTS: Nginx
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Jason (idometeor@gmail.com),
#  ORGANIZATION: @iDoMeteor
#       CREATED: 01/01/2018 08:44
#      REVISION:  ---
#===============================================================================

# Strict mode
set -euo pipefail
IFS=$'\n\t'

# Constants
HOSTNAMEREGEX="^(([a-zA-Z0-9]|[a-zA-Z0-9][a-zA-Z0-9\-]*[a-zA-Z0-9])\.)*([A-Za-z0-9]|[A-Za-z0-9][A-Za-z0-9\-]*[A-Za-z0-9])$"
NUMSCRIPTS=4 # This * number of test objects calculates test pass/fail rate
NUMOBJECTS=0 # This * number of test objects calculates test pass/fail rate
RECIPIENTS="idometeor@gmail.com"
SELFROOT=`dirname $0`
TESTOBJECTS="test-objects.txt"

# Variables
EXPECTED=0 # Expected exit code
PASS=0 # Number of tests passed (met expectations)
FAIL=0 # Number of tests failed (did not meet expectations)

while read value
do
  let NUMOBJECTS+=1
  if [[ $HOST =~ $HOSTNAMEREGEX ]] ; then
    # If test object passes regex, it should pass the tests
    EXPECTED=0
  else
    # If test object fails regex, it should fail the tests
    EXPECTED=1
  fi
  # Test virtual host configuration file creation
  nginx-add-php-vhost.sh -h $HOST -y
  if [ 0 -eq $? && 0 -eq $EXPECTED ] ; then
    let PASS+=1
  elif [ 1 -eq $? && 1 -eq $EXPECTED ] ; then
    let PASS+=1
  else
    let FAIL+=1
  fi
  if [ -v VERBOSE ] ; then
    echo "nginx-add-php-vhost.sh -h $HOST -y test result: $?"
  fi
  # Test virtual host configuration file disable
  nginx-disable-vhost.sh -h <FQDN> [-v] [-y]
  if [ 0 -eq $? && 0 -eq $EXPECTED ] ; then
    let PASS+=1
  elif [ 1 -eq $? && 1 -eq $EXPECTED ] ; then
    let PASS+=1
  else
    let FAIL+=1
  fi
  if [ -v VERBOSE ] ; then
    echo "nginx-disable-vhost.sh -h $HOST -y test result: $?"
  fi
  # Test virtual host configuration file enable
  nginx-enable-vhost.sh -h <FQDN> [-v] [-y]
  if [ 0 -eq $? && 0 -eq $EXPECTED ] ; then
    let PASS+=1
  elif [ 1 -eq $? && 1 -eq $EXPECTED ] ; then
    let PASS+=1
  else
    let FAIL+=1
  fi
  if [ -v VERBOSE ] ; then
    echo "nginx-enable-vhost.sh -h $HOST -y test result: $?"
  fi
  # Test virtual host configuration file removal
  nginx-remove-vhost.sh -h <FQDN> [-v] [-y]
  if [ 0 -eq $? && 0 -eq $EXPECTED ] ; then
    let PASS+=1
  elif [ 1 -eq $? && 1 -eq $EXPECTED ] ; then
    let PASS+=1
  else
    let FAIL+=1
  fi
  if [ -v VERBOSE ] ; then
    echo "nginx-remove-vhost.sh -h $HOST -y test result: $?"
  fi
done < $SELFROOT/$TESTOBJECTS

# Calculate
let PERCENTAGE=$PASS/$NUMOBJECTS*100

# Report
echo "Number of scripts tested: $NUMSCRIPTS"
echo "Number of objects tested: $NUMOBJECTS"
echo "Number of objects passed: $PASS"
echo "Number of objects failed: $FAIL"
echo "Percentage successful: $PERCENTAGE"
