#!/bin/bash -
#===============================================================================
#
#          FILE: nginx-add-php-vhost.sh
#
#         USAGE: nginx-add-php-vhost.sh -h host [-v] [-y]
#                nginx-add-php-vhost.sh --host host [--verbose] [--yes]
#
#   DESCRIPTION: This script will add a virtual host configuration file to
#                 the Nginx sites-available/ directory and then creates a
#                 symbolic link to that file in sites-enabled/.
#       OPTIONS:
#                -h | --host
#                   The fully qualified domain name of the virtual host.
#                -v | --verbose
#                   If passed, will show all commands executed.
#                -y | --yes
#                   Passing the force flag will suppress the prompt to restart
#                     nginx and just do it.
#  REQUIREMENTS: Nginx
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Jason White (idometeor@gmail.com),
#  ORGANIZATION: @iDoMeteor
#       CREATED: 04/15/2016 15:33
#      REVISION:  001
#          TODO: Make template system more configurable
#===============================================================================

# Strict mode
set -euo pipefail
IFS=$'\n\t'

# Check for arguments or provide help
if [ $# -eq 0 ] ; then
  echo "Usage:"
  echo "  `basename $0` -h host [-v] [-y]"
  echo "  `basename $0` --host host [--verbose] [--yes]"
  exit 0
fi

# Check for root
WHO=`whoami`
if [ 'root' != $WHO ] ; then
  echo "`basename` $0 must be run as root."
  exit 1
fi

# Check for template
SELFROOT=`dirname $0`
if [ ! -d $SELFROOT/templates ] ; then
  echo "`basename` $0/templates does not exist, cannot continue."
  exit 1
fi
if [ ! -f $SELFROOT/templates/php-subdomain.conf ] ; then
  echo "`basename` $0/templates/php-subdomain.conf does not exist, cannot continue."
  exit 1
fi

# Parse command line arguments into variables
while :
do
    case ${1:-} in
      -h | --host)
    HOST="$2"
    shift 2
    ;;
      -v | --verbose)
    VERBOSE=true
    shift 1
    ;;
      -y | --yes)
    YES=true
    shift 1
    ;;
      -*)
    echo "Error: Unknown option: $1" >&2
    exit 1
    ;;
      *)  # No more options
    break
    ;;
    esac
done

# Validate arguments
if [ ! -v HOST ] ; then
  echo 'Host name is required.'
  exit 1
fi
if [ -f /etc/nginx/sites-available/$HOST\.conf ] ; then
  echo 'Virtual host configuration already exists.'
  exit 1
fi
if [ -L /etc/nginx/sites-enabled/$HOST\.conf ] ; then
  echo 'Virtual host configuration is already enabled.'
  exit 1
fi

# Check verbosity
if [ -v VERBOSE ] ; then
  set -v
fi

# Create /etc/nginx/sites-available/$HOST.conf
source templates/php-subdomain.conf | tee /etc/nginx/sites-available/$HOST.conf

# Enable
ln -s /etc/nginx/sites-available/$HOST.conf /etc/nginx/sites-enabled/$HOST.conf

# Restart Nginx
if [ -v YES ] ; then
  nginx -t && service nginx reload
  if [ 0 -ne $? ] ; then
    echo "Failed to reload Nginx"
    exit 1
  fi
else
  read -p "Would you like me to reload Nginx for you? [y/N] " -n 1 -r REPLY
  echo ""
  if [[ $REPLY =~ ^[Yy]$ ]] ; then
    nginx -t && service nginx reload
    if [ 0 -ne $? ] ; then
      echo "Failed to reload Nginx"
      exit 1
    fi
  fi
fi

exit 0
