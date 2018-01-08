#!/bin/bash -
#===============================================================================
#
#          FILE: nginx-enable-vhost.sh
#
#         USAGE: nginx-enable-vhost.sh -h <FQDN> [-v] [-y]
#                nginx-enable-vhost.sh --host <FQDN> [--verbose] [--yes]
#
#   DESCRIPTION: This script will add a virtual host configuration file to
#                 the Nginx sites-available/ directory and then creates a
#                 symbolic link to that file in sites-enabled/.
#       OPTIONS:
#                -h | --host
#                   The fully qualified domain name of the virtual host.
#                -r | --root
#                   Document root for the PHP application
#                -u | --user
#                   The name of the system account the host will be attributed to.
#                -v | --verbose
#                   If passed, will show all commands executed.
#                -y | --yes
#                   Passing the force flag will suppress the prompt to restart
#                     nginx and just do it.
#  REQUIREMENTS: Nginx
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Jason (idometeor@gmail.com),
#  ORGANIZATION: @iDoMeteor
#       CREATED: 12/17/2017 15:34
#      REVISION:  001
#          TODO: Refactor Nginx part into a function all scripts can use
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
  echo 'A fully qualified domain or host name is required.'
  exit 1
fi
if [ ! -f /etc/nginx/sites-available/$HOST\.conf ] ; then
  echo 'Virtual host configuration does not exist, cannot enable.'
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

# Get'er done
ln -s /etc/nginx/sites-available/$HOST.conf /etc/nginx/sites-enabled/$HOST.conf
if [ 0 -ne $? ] ; then
  echo "Failed to link $HOST.conf"
  exit 1
fi

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
