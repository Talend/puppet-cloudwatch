#!/usr/bin/env python
# coding: utf8

"""CloudWatch Agent

Usage:
  cloudwatch-agent.py [-d | --debug]
  cloudwatch-agent.py (-h | --help)

Options:
  -d --debug    Set a more verbose logging.
  -h --help     Show this screen.

"""

from docopt import docopt
import logging
import logging.config
import yaml


def main(kwargs):

    print("Loading configuration & initializing logging")
    configuration = yaml.load("configuration.yaml")

    logging.config.dictConfig(configuration['logging'])

# --------------

if __name__ == '__main__':
    arguments = docopt(__doc__)
    main(arguments)
