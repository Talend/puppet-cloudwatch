#!/usr/bin/env sh

COMMAND=$(which df)
EXECUTE=$( $COMMAND -H | grep -vE '^Filesystem|tmpfs|cdrom|udev|mapper|Datei' | awk '{ print $5 " " $1}')

logger "CloudWatchMetric - DiskSpace / $EXECUTE"
echo $EXECUTE