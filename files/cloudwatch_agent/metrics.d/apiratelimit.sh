#!/bin/sh

# Shell script run by CloudWatch Agent to get remaining GitHub API calls in rate limit.
#
# Options :
#     -p : Display result as a PERCENT of total calls instead of number.
#     -u : User for which to get remaining API calls. Values: 'bot' or 'build'
#     -h : Display this usage
#
# Copyright 2017 Talend

# ---------
# Functions
# ---------

function usage {
    echo "$0 [-hpu]

    Shell script run by CloudWatch Agent to get remaining GitHub API calls in rate limit.
    Options :
        -p : Display result as a PERCENT of total calls instead of number.
        -u : User for which to get remaining API calls. Values: 'bot' or 'build'
        -h : Display this usage
    "
}

function parse_args {

    while getopts pu:h flag; do
        case $flag in
            p)
                PERCENT="TRUE";
                ;;
            u)
                if [[ "$OPTARG" != "bot" ]] && [[ "$OPTARG" != "build" ]]; then
                   echo User must be either \'bot\' or \'build\'.
                   exit 1
                fi;
                USER="$OPTARG";
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
    USER="bot"
    parse_args $@
    echo Checking remaining API calls for \'$USER\'
    export PATH=$PATH:/usr/local/bin
    if [[ "$USER" == "bot" ]]; then
        GITHUB_TOKEN=`cat /var/lib/jenkins/.config/hub | yq ".[][0].oauth_token" | tr -d '"'`
    else
        GITHUB_TOKEN=""
    fi

    rate_limit=$(curl -s -H "Authorization: token ${GITHUB_TOKEN}"  https://api.github.com/rate_limit)
    remaining=$(echo $rate_limit | /usr/local/bin/jq '.rate.remaining')
    limit=$(echo $rate_limit | /usr/local/bin/jq '.rate.limit')

    if [[ "$PERCENT" == "TRUE" ]]; then
      RESULT=$((100*$remaining/$limit))
    else
      RESULT=$remaining
    fi


    logger "CloudWatchMetric - BotApiRateLimit"
    echo $RESULT

}

main $@