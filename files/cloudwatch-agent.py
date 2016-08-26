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

from docopt import docopt
import logging.config
import os
import subprocess
import sys
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
        func(*args, **kwargs)
        logger.log(level, "END - {0}".format(func.__name__))

    return log_steps


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
    available_scripts = [f
                         for f
                         in os.listdir(metrics_path)
                         if os.path.isfile(os.path.join(metrics_path, f))]

    logger.debug("Found scripts : {0}".format(available_scripts))

    # Match requested metric scripts and available ones
    # Notes :
    #   * matches are made in lower cases to have case insensitive behaviour
    #   * File extension is not taken in account for matching names
    script_to_run = []
    for metric in metrics:

        found = False
        metric_name = metric['name'].lower()

        for script in available_scripts:
            if script.lower().split('.')[0] == metric_name:
                found = True
                script_to_run.append('{0}/{1} {2}'.format(metrics_path,
                                                          script,
                                                          metric['params']))
                break;

        if not found:
            logger.error("Requested metric script %s was not found in %s", metric['name'], metrics_path)

    logger.debug("Metric script scheduled to run : %s", script_to_run)

    # Run found scripts
    if not script_to_run:
        logger.critical("No metric script to run !")
        sys.exit(1)

    for script in script_to_run:
        try:
            output = subprocess.check_output([script], stderr=subprocess.STDOUT)

            logger.debug("Script %s output : %s", script, output)

        except subprocess.CalledProcessError as e:
            logger.error("Script %s failed : %s", script, e)


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
