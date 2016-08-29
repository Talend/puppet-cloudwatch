#!/usr/bin/env python
# coding: utf8

"""CloudWatch Agent

Usage:
  cloudwatch-agent.py [-d | --debug] -c <file> | --config <file>
  cloudwatch-agent.py (-h | --help)

Options:
  -c <file> --config <file>   Absolute path to a YAML configuration file
  -d        --debug           Set a more verbose logging.
  -h        --help            Show this screen.

"""

from boto import utils
import botocore
import boto3
from docopt import docopt
import logging.config
import os
import subprocess
import yaml

# ---------
# Functions
# ---------


def print_steps(func, level=logging.INFO):
    """
    Used as a decorator to print a log message using the logger at the beginning & the end of execution of the decorated
    function.

    :param func:  the decorated function
    :param level: Level of the log message. Default : logging.INFO
    :type  func:  Object (a function)
    :type  level: Integer (using 'logging' constants for log levels)
    :return:      Inner function 'log_steps'.
    """

    def log_steps(*args, **kwargs):
        """
        Inner function to print the log messages
        :param args:   args from the decorator to give to the decorated function
        :param kwargs: kwargs from the decorator to give to the decorated function
        :return:       None
        """
        logger.log(level, "BEGIN - {0}".format(func.__name__))
        output = func(*args, **kwargs)
        logger.log(level, "END - {0}".format(func.__name__))
        return output

    return log_steps


@print_steps
def run_metric_scripts(metrics_path, metrics, scripts):
    """
    Match requested metric scripts and available ones
    Notes :
      * matches are made in lower cases to have case insensitive behaviour
      * File extension is not taken in account for matching names

    :param metrics_path: Absolute path to the place where scripts are stored
    :param metrics:      List of metrics (in dicts) required
    :param scripts:      List of scripts found
    :return:             A list of metric data to push in CloudWatch (Dict format for Boto)
    """

    metrics_values = []
    for metric in metrics:

        found = False
        metric_name = metric['name'].lower()

        for script in scripts:

            # Run command if the script is found for the requested metric
            if script.lower().split('.')[0] == metric_name:

                found = True
                script = ["{0}/{1}".format(metrics_path, script), metric['params']]

                process = subprocess.Popen(script, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
                stdout, stderr = process.communicate()

                if process.returncode != 0:
                    logger.error("Script %s failed (return code %s) : %s", script, process.returncode, stderr)
                else:
                    logger.debug("Script %s output : %s", script, stdout)

                    # Metric results to be pushed later on
                    metrics_values.append({
                        'MetricName': metric['name'],
                        'Value': float(metric['value']),
                        'Unit': metric['unit']
                    })

                break

        if not found:
            logger.error("Requested metric script %s was not found in %s", metric['name'], metrics_path)

    return metrics_values


@print_steps
def set_aws_region():
    """
    Set an environment variable AWS_DEFAULT_REGION with the name of the AWS Region got from instance metadata.
    :return: None
    """
    aws_region = utils.get_instance_metadata(data='meta-data/placement/')['availability-zone'][:-1]
    logger.debug("AWS Region : %s", aws_region)

    os.environ["AWS_DEFAULT_REGION"] = aws_region


@print_steps
def push_cloudwatch(request):
    """
    Push a list of metrics data in CloudWatch using Boto3.
    :param request:
    :return:
    """

    if request:
        logger.debug("Metrics values to push : %s", request)

        try:
            cloudwatch = boto3.client('cloudwatch')
            cloudwatch.put_metric_data(Namespace=configuration['namespace'],
                                       MetricData=request)

        except botocore.exceptions.BotoCoreError as e:
            logger.critical(e)
    else:
        logger.error('No metrics data to send !')


@print_steps
def main(kwargs):
    """
    Main function.
    :param kwargs: Arguments given by docopt.
    :return:       None
    """

    # Get the list of requested metrics for this instance
    logger.info('Get metric configuration')

    metrics = configuration['metrics']
    logger.debug("Configured metrics : {0}".format(metrics))

    # Get the list of available scripts (without any file extension)
    logger.info('Get available scripts')

    metrics_path = "{0}/metrics.d".format(os.path.dirname(os.path.realpath(__file__)))
    available_scripts = [f for f in os.listdir(metrics_path) if os.path.isfile(os.path.join(metrics_path, f))]

    logger.debug("Found scripts : {0}".format(available_scripts))

    # Execute all matches
    cloudwatch_request = run_metric_scripts(metrics_path, metrics, available_scripts)
    set_aws_region()
    push_cloudwatch(cloudwatch_request)

    # Statistics
    logger.info("CloudWatch agent statistics : %s/%s (Pushed metrics / Requested metrics)",
                len(cloudwatch_request),
                len(metrics))


if __name__ == '__main__':
    arguments = docopt(__doc__)

    with open(arguments['--config']) as f:
        configuration = yaml.load(f)

        logging.config.dictConfig(configuration['logging'])

        if arguments['--debug']:
            logger = logging.getLogger('cloudwatch-agent-cli')
        else:
            logger = logging.getLogger('cloudwatch-agent')

        main(arguments)
