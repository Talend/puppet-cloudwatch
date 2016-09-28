#!/usr/bin/env sh

# Shell script by CloudWatch Agent to get Docker related informations.
#
# Options :
#     -f : Filter to use when collecting Docker informations.
#     -h : Display this usage
#
# Copyright 2016 Talend

# ---------
# Constants
# ---------

# Default value if nothing is requested : root mount point
FILTER="Running"

# ---------
# Functions
# ---------

function usage {
    echo "$0 [-h] -f <filter>

    Shell script by CloudWatch Agent to get Docker related informations.
    Options :
        -f : Filter to use when collecting Docker informations
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

    # "docker info" needs root rights
    COMMAND=$(which docker)
    RESULT=$( sudo $COMMAND info 2>/dev/null | grep "$FILTER" | awk 'BEGIN { FS = ":" }; { print $2}' | xargs)

    logger "CloudWatchMetric - Docker info for $FILTER / $RESULT"
    echo $RESULT

}

main $@
