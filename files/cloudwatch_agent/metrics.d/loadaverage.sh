#!/usr/bin/env sh

# Shell script by CloudWatch Agent to get the percentage metric that represent
# loadaverage during last minute depending to the number of cpu cores.
# The load average represents the average system load over a period of time.
# It conventionally appears in the form of three numbers which represent the
# system load during the last one-, five-, and fifteen-minute periods.
# Copyright 2016 Talend

function usage {
    echo "$0

    Shell script by CloudWatch Agent to get percentage metric.
    the loadaverage for the last minute divised by the number of vcpu owned
    by the instance.

    Copyright 2017 Talend
    "
}

COMMAND_BC=$(which bc)
LOAD1=$(cat /proc/loadavg | cut -d ' ' -f 1)
NB_VCPU=$(cat /proc/cpuinfo |grep processor |tail -n1| cut -d ':' -f 2)
PERCENT=$(${COMMAND_BC} <<< "scale = 2; ${LOAD1} / (${NB_VCPU} + 1) * 100")

logger "CloudWatchMetric - loadaverage1min/NumberOfVCPU / ${PERCENT}"
echo ${PERCENT}
