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


def main(arguments):
    print arguments

if __name__ == '__main__':
    arguments = docopt(__doc__)
    main(arguments)
