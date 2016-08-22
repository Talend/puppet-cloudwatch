#!/usr/bin/env bash


# Main script of cloudwatch-agent : search for a set of metric scripts and executes them based on a configuration file.
# Usually set in Cron.
#
# Configuration files :
#    cloudwatch-agent.conf : list of metric to run with parameters.
#
# Copyright 2016 Talend

################################
# Global variables & constants #
################################

readonly BASE_DIR=$(dirname $(realpath $0))
readonly AWS_CLI=$(which aws)

#############
# Functions #
#############

# Check if all mandatory variables are there.
#
# Exit code :
#    1 : if any missing variable
function check_env() {

    # Stores potential errors
    declare -a errors

    if  [[ ! "$AWS_CLI" =~ ^/.*/aws$ ]]
    then
        errors+=('ERROR: No AWS CLI found in PATH')
    fi

    # Display errors if any
    if [[ -n $errors ]]; then

        for error in "${errors[@]}"
        do
            echo "$error" >2
        done

        exit 1
    fi
}

function collect() {
    find $METRICS_PATH -type f -executable -print
}

function send_metrics() {
    echo "$AWSCLI cloudwatch put-metric-data \
    --metric-name $1 \
    --namespace $2 \
    --value $3 \
    --timestamp $(date --utc +%FT%TZ) "
}

function measure () {

  METRIC_NAME=$(echo $1 | cut -f6 -d'/')
  METRIC_NAMESPACE=<%= @metrics_namespace %>
  METRIC_DATA=$( echo $( $1 )| tr ' ', ';' )

  send_metrics $METRIC_NAME $METRIC_NAMESPACE $METRIC_DATA
}

function main() {

    # Load configuration & do checks
    source "$0.conf"
    check_env

    for file_path in $(collect)
    do
        measure $file_path
    done
}

main $@
