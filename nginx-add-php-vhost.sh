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
#
#          TODO: Make template system more configurable
#                ORGANIZE IN DIRS BY STARTING CHAR!
#
#===============================================================================

# Strict mode
set -euo pipefail
IFS=$'\n\t'

# Constants
HOSTNAMEREGEX="^[0-9a-zA-Z][0-9a-zA-Z-_]{0,100}[0-9a-zA-Z]"
SELFROOT=`dirname $0`

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
if [[ $HOST =~ $HOSTNAMEREGEX ]] ; then
  SUBDIR=${HOST:0:1}
else
  echo 'Invalid host name supplied.'
  exit 1
fi
if [ ! -d /etc/nginx/sites-available/$SUBDDIR ] ; then
  mkdir -p /etc/nginx/sites-available/$SUBDIR
fi
if [ ! -d /etc/nginx/sites-enabled/$SUBDDIR ] ; then
  mkdir -p /etc/nginx/sites-enabled/$SUBDIR
fi
if [ -f /etc/nginx/sites-enabled/$SUBDIR/$HOST\.conf ] ; then
    mv /etc/nginx/sites-enabled/$SUBDIR/$HOST.conf /etc/nginx/sites-enabled/$SUBDIR/$HOST.conf.bak
fi
if [ -L /etc/nginx/sites-enabled/$SUBDIR/$HOST\.conf ] ; then
  rm -f /etc/nginx/sites-enabled/$SUBDIR/$HOST.conf
fi
if [ -f /etc/nginx/sites-available/$SUBDIR/$HOST\.conf ] ; then
    mv /etc/nginx/sites-available/$SUBDIR/$HOST.conf /etc/nginx/sites-available/$SUBDIR/$HOST.conf.bak
else
fi

# Check verbosity
if [ -v VERBOSE ] ; then
  set -v
fi


# Create /etc/nginx/sites-available/$HOST.conf
if [ -f $SELFROOT/nginx-echo-template.sh ] ; then
  source $SELFROOT/nginx-echo-template.sh | tee /etc/nginx/sites-available/$SUBDIR/$HOST.conf
else
  echo "Cannot source global template, cannot continue."
  exit 1
fi

# Enable
ln -s /etc/nginx/sites-available/$SUBDIR/$HOST.conf /etc/nginx/sites-enabled/$SUBDIR/$HOST.conf
if [ 0 -ne $? ] ; then
  echo "Failed to enable host file."
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
