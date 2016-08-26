#! /bin/bash

COMMAND=$(which free)
EXECUTE=$($COMMAND -m | grep Mem | cut -d' ' -f21)

logger "CloudWatchMetric - memory / $EXECUTE"
echo $EXECUTE
