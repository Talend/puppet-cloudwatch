#!/usr/bin/env python
# coding: utf8

"""CloudWatch Agent

Usage:
  cw_agent.py [-d | --debug] -c <file> | --config <file>
  cw_agent.py (-h | --help)

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


class CWAgent:
    """
    Main class of the CloudWatch Agent
    """

    def __init__(self, configuration, debug=False):
        """
        Load configuration & logging
        """

        self.configuration = configuration
        logging.config.dictConfig(configuration['logging'])

        if debug:
            self.logger = logging.getLogger('cloudwatch-agent-cli')
        else:
            self.logger = logging.getLogger('cloudwatch-agent')

    def run_metric_scripts(self, metrics_path, metrics, scripts):
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

        self.logger.info('Get metrics values')

        metrics_values = []
        for metric in metrics:

            found = False
            metric_name = metric['name'].lower()

            for script in scripts:

                # Run command if the script is found for the requested metric
                if script.lower().split('.')[0] == metric_name:

                    found = True
                    script = ["{0}/{1}".format(metrics_path, script), metric['params']]

                    self.logger.debug('Ready to execute %s', script)

                    process = subprocess.Popen(script, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
                    stdout, stderr = process.communicate()

                    if process.returncode != 0:
                        self.logger.error("Script %s failed (return code %s) : %s", script, process.returncode, stderr)

                    else:
                        self.logger.debug("Script %s output : %s", script, stdout)

                        # Metric results to be pushed later on
                        metrics_values.append({
                            'MetricName': metric['name'],
                            'Value': float(stdout),
                            'Unit': metric['unit']
                        })

                    break

            if not found:
                self.logger.error("Requested metric script %s was not found in %s", metric['name'], metrics_path)

        return metrics_values

    def set_aws_region(self):
        """
        Set an environment variable AWS_DEFAULT_REGION with the name of the AWS Region got from instance metadata.
        :return: None
        """
        aws_region = utils.get_instance_metadata(data='meta-data/placement/')['availability-zone'][:-1]
        self.logger.debug("AWS Region : %s", aws_region)

        os.environ["AWS_DEFAULT_REGION"] = aws_region

    def push_cloudwatch(self, request):
        """
        Push a list of metrics data in CloudWatch using Boto3.
        :param request:
        :return:
        """
        self.logger

        if request:
            self.logger.debug("Metrics values to push : %s", request)

            try:
                cloudwatch = boto3.client('cloudwatch')
                cloudwatch.put_metric_data(Namespace=configuration['namespace'],
                                           MetricData=request)

            except botocore.exceptions.BotoCoreError as e:
                self.logger.critical(e)
        else:
            self.logger.error('No metrics data to send !')

    def run(self):
        """
        Run the agent.
        """

        self.logger.info('New run of CloudWatch Agent')

        metrics = configuration['metrics']
        self.logger.debug("Configured metrics : {0}".format(metrics))

        metrics_path = "{0}/metrics.d".format(os.path.dirname(os.path.realpath(__file__)))
        available_scripts = [f for f in os.listdir(metrics_path) if os.path.isfile(os.path.join(metrics_path, f))]

        self.logger.debug("Found scripts : {0}".format(available_scripts))

        # Execute all matches
        cloudwatch_request = self.run_metric_scripts(metrics_path, metrics, available_scripts)
        self.set_aws_region()

        try:
            self.push_cloudwatch(cloudwatch_request)

        except botocore.exceptions.BotoCoreError as e:
            self.logger.critical(e)

        # Statistics
        self.logger.info("CloudWatch agent statistics : %s/%s (Pushed metrics / Requested metrics)",
                         len(cloudwatch_request),
                         len(metrics))


if __name__ == '__main__':
    arguments = docopt(__doc__)

    with open(arguments['--config']) as f:
        configuration = yaml.load(f)

        agent = CWAgent(configuration, arguments['--debug'])
        agent.run()
