#!/usr/bin/env sh

COMMAND=$(which free)
EXECUTE=$($COMMAND -m | grep Mem | awk '{ print $3 }')

logger "CloudWatchMetric - memory / $EXECUTE"
echo $EXECUTE
