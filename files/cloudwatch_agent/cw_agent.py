#!/usr/bin/env python
# coding: utf8

"""CloudWatch Agent

Usage:
  cw_agent.py [-d] (-m <file> | --metrics=<file>)
  cw_agent.py -h | --help

Options:
  -m <file>, --metrics=<file>  Absolute path to the YAML file specifying requested monitoring metrics.
  -d, --debug                  Set a more verbose logging.
  -h, --help                   Show this screen.

"""

from __future__ import print_function

from boto import utils
import botocore
import boto3
from docopt import docopt
import logging.config
import os
import subprocess
import yaml

# -----------------------
# Configuration & logging
# -----------------------

script_dir = os.path.dirname(os.path.realpath(__file__))

conf_file = "{0}/configuration.yaml".format(script_dir)
configuration = yaml.load(open(conf_file))

log_config = configuration['logging']
logging.config.dictConfig(log_config)

LOG = logging.getLogger('CWAgent')


class CWAgent(object):
    """
    Main class of the CloudWatch Agent
    """

    def __init__(self, metrics, debug=False):
        """
        Load configuration & logging

        :param metrics:       Dict with requested monitoring metrics
        """

        self.metrics = metrics['metrics']
        self.namespace = metrics['namespace']

        if debug:
            LOG.setLevel(logging.DEBUG)

    def log_steps(func):

        def do_log_steps(*args, **kwargs):

            LOG.info("BEGIN - %s", func.__name__)
            result = func(*args, **kwargs)
            LOG.info("END - %s", func.__name__)
            return result

        return do_log_steps

    @log_steps
    def run_metric_scripts(self, metrics_path, scripts):
        """
        Match requested metric scripts and available ones
        Notes :
          * matches are made in lower cases to have case insensitive behaviour
          * File extension is not taken in account for matching names

        :param metrics_path: Absolute path to the place where scripts are stored
        :param scripts:      List of scripts found
        :return:             A list of metric data to push in CloudWatch (Dict format for Boto)
        """

        LOG.info('Get metrics values')

        metrics_values = []
        for metric in self.metrics:

            found = False
            metric_name = metric['name'].lower()

            for script in scripts:

                # Run command if the script is found for the requested metric
                if script.lower().split('.')[0] == metric_name:

                    found = True
                    script = ["{0}/{1}".format(metrics_path, script), metric['params']]

                    LOG.debug('Ready to execute %s', script)
                    try:

                        process = subprocess.Popen(script, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
                        stdout, stderr = process.communicate()

                        if process.returncode != 0:
                            raise Exception("Script {0} failed (return code {1}) : {2}".format(script,
                                                                                               process.returncode,
                                                                                               stderr))

                        else:
                            LOG.debug("Script %s output : %s", script, stdout)

                            # Metric results to be pushed later on
                            metrics_values.append({
                                'MetricName': metric['name'],
                                'Value': float(stdout),
                                'Unit': metric['unit'],
                                'Dimensions': [{
                                    'Name': 'InstanceID',
                                    'Value': utils.get_instance_metadata(data='meta-data/')['instance-id']
                                }]
                            })

                    except Exception as e:
                        LOG.error("Error during metric script execution : %s", e)

                    break

            if not found:
                LOG.error("Requested metric script %s was not found in %s", metric['name'], metrics_path)

        return metrics_values

    @log_steps
    def set_aws_region(self):
        """
        Set an environment variable AWS_DEFAULT_REGION with the name of the AWS Region got from instance metadata.
        :return: None
        """
        aws_region = utils.get_instance_metadata(data='meta-data/placement/')['availability-zone'][:-1]
        LOG.debug("AWS Region : %s", aws_region)

        os.environ["AWS_DEFAULT_REGION"] = aws_region

    @log_steps
    def push_cloudwatch(self, request):
        """
        Push a list of metrics data in CloudWatch using Boto3.
        :param request:
        :return:
        """
        LOG

        if request:
            LOG.debug("Metrics values to push : %s", request)

            try:
                cloudwatch = boto3.client('cloudwatch')
                cloudwatch.put_metric_data(Namespace=self.namespace,
                                           MetricData=request)

            except botocore.exceptions.BotoCoreError as e:
                LOG.critical(e)
        else:
            LOG.error('No metrics data to send !')

    @log_steps
    def run(self):
        """
        Run the agent.
        """

        LOG.info('New run of CloudWatch Agent')

        metrics_path = "{0}/metrics.d".format(os.path.dirname(os.path.realpath(__file__)))
        available_scripts = [f for f in os.listdir(metrics_path) if os.path.isfile(os.path.join(metrics_path, f))]

        LOG.debug("Found scripts : {0}".format(available_scripts))

        # Execute all matches
        cloudwatch_request = self.run_metric_scripts(metrics_path, available_scripts)
        self.set_aws_region()

        try:
            self.push_cloudwatch(cloudwatch_request)

        except botocore.exceptions.BotoCoreError as e:
            LOG.critical(e)

        # Statistics
        LOG.info("CloudWatch agent statistics : %s/%s (Pushed metrics / Requested metrics)",
                         len(cloudwatch_request),
                         len(self.metrics))


if __name__ == '__main__':
    arguments = docopt(__doc__)

    LOG.info('---- CloudWatch Agent - START ----')
    LOG.debug("Arguments : %s", arguments)

    try:
        metrics_file = open(arguments['--metrics'])

        agent = CWAgent(yaml.load(metrics_file), arguments['--debug'])
        agent.run()

        LOG.info('---- CloudWatch Agent - END ----')

    except Exception:
        LOG.exception('Error during CloudWatch Agent execution')
