#!/bin/sh

# Shell script by CloudWatch Agent to get the percentage of used space on a filesystem.
#
# Options :
#     -f : Filesystem or mount point to monitor. Can be a block device name (/dev/sda) or a mount point (/usr).
#          Note : this filter will be applied on Filesystem first then in mount point. Also the value should strictly
#          match either the filesystem or the mount point (no wildcard or regex allowed)
#     -h : Display this usage
#
# Copyright 2016 Talend

# ---------
# Constants
# ---------

# Default value if nothing is requested : root mount point
FILTER="/"

# ---------
# Functions
# ---------

function usage {
    echo "$0 [-h] -f <filter>

    Shell script by CloudWatch Agent to get the percentage of used space on a filesystem.
    Options :
        -f : Filesystem or mount point to monitor. Can be a block device name (/dev/sda) or a mount point (/usr).
             Note : this filter will be applied on Filesystem first then in mount point. Also the value should strictly
             match either the filesystem or the mount point (no wildcard or regex allowed)
        -h : Display this usage
    "
}

function parse_args {

    while getopts f:h flag; do
        case $flag in
            f)
                FILTER="$OPTARG";
                ;;
            h)
                usage;
                exit 0;
                ;;
            ?)
                usage;
                exit 1;
                ;;
        esac
    done

    shift $(( OPTIND - 1 ));
}

function main {

    # Parse script arguments & parameters
    parse_args $@

    COMMAND=$(which df)
    RESULT=$( $COMMAND -H --output='source,target,pcent' | awk -v FILTER="$FILTER" '{ if ($1 == FILTER || $2 == FILTER) print $3}')

    # Remove unwanted % character
    RESULT=${RESULT::-1}

    logger "CloudWatchMetric - DiskSpace for $FILTER / $RESULT"
    echo $RESULT

}

main $@