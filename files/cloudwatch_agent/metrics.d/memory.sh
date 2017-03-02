#!/bin/sh

# Shell script by CloudWatch Agent to get the percentage of used memory
#
# Copyright 2016 Talend

function usage {
    echo "$0

    Shell script by CloudWatch Agent to get the percentage of used memory

    Copyright 2017 Talend
    "
}

COMMAND=$(which free)
COMMAND_BC=$(which bc)
USED=$(${COMMAND} -m | grep Mem | awk '{ print $3 }')
TOTAL=$(${COMMAND} -m | grep Mem | awk '{ print $2 }')
PERCENT=$(${COMMAND_BC} <<< "scale = 2; ${USED} / ${TOTAL} * 100")


logger "CloudWatchMetric - memory / ${PERCENT}"
echo ${PERCENT}
