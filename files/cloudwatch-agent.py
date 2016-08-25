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
import logging
import logging.config
import yaml

# ---------
# Functions
# ---------


def print_steps(func, level=logging.INFO):

    def log_steps(*args, **kwargs):
        logger.log(level, "BEGIN - {0}".format(func.__name__))
        func(*args, **kwargs)
        logger.log(level, "END - {0}".format(func.__name__))

    return log_steps


@print_steps
def main(kwargs):

    # Match configuration with found scripts
    # -> error log for every missing script
    # -> execute all found scripts
    logger.info("Get metric configuration")

    metrics = configuration["metrics"]

    logger.debug("Configured metrics : {0}".format(metrics))

    # Use multiprocess to run scripts
    # -> error log for failing scripts
    # -> store values for all successful scripts

    # Loop results to push them to CloudWatch using Boto


# ---------

if __name__ == '__main__':
    arguments = docopt(__doc__)

    with open(arguments["--config"]) as f:
        configuration = yaml.load(f)

        logging.config.dictConfig(configuration["logging"])
        logger = logging.getLogger("cloudwatch-agent")

        main(arguments, configuration)
