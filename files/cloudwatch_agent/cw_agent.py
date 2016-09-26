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

conf_file = "{0}/logging.yaml".format(script_dir)
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
    def evaluate_metrics(self, metrics):
        """
        Evaluate metrics using subprocesses to run scripts.

        :param metrics: Dict of metric to evaluate
        :return:        A list of metrics data to push in CloudWatch (Dict format for Boto)
        """

        LOG.info('Get metrics values')

        metrics_values = []

        for metric_name, metric_spec in metrics.iteritems():

            script = [metric_spec['script'], metric_spec['params']]

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
                    metric_result = {'MetricName': metric_name,
                                     'Unit': metric_spec['unit']}

                    # Manage result type
                    if metric_spec['unit'] == 'None':
                        metric_result['Value'] = stdout
                    else:
                        metric_result['Value'] = float(stdout)

                        # Manage dimensions
                        metric_result['Dimensions'] = self.get_metric_dimensions(metric_spec['dimensions'])

                        metrics_values.append(metric_result)

            except Exception as e:
                LOG.error("Error during metric script execution : %s", e)

        return metrics_values

    @log_steps
    def get_metric_dimensions(self, requested_dimensions):
        """
        Evaluate a list of CloudWatch dimensions requested by a metric.
        Requested dimensions will be evaluated by a method using the same name as the dimension.

        Default dimensions for all metrics :
        * InstanceID : value got from the instance metadata

        :return: List of evaluated dimensions
        """

        evaluated_dimensions = [{
            'Name': 'InstanceID',
            'Value': utils.get_instance_metadata(data='meta-data/')['instance-id']
        }]

        for dimension in requested_dimensions:

            try:
                value = getattr(self, "get_dimension_{0}".format(dimension))
                evaluated_dimensions.append(value)

            except AttributeError:
                LOG.error("Dimension %s is not implemented in the CloudWatch Agent", dimension)
                break

        return evaluated_dimensions

    @staticmethod
    @log_steps
    def get_dimension_ECSCluster():
        """
        Get the name of the ECS Cluster this instance is part of.

        :return: CloudWatch dimension named ECSCluster
        """

        ecs_cluster = 'Blabla'

        return {'ECSCluster' : ecs_cluster}

    @staticmethod
    @log_steps
    def match_metrics(requested_metrics, available_scripts, scripts_path):
        """
        Match requested metrics with available scripts on this agent.
        Return a dict of metrics to be evaluated.

        Notes :
          * matches are made in lower cases to have case insensitive behaviour
          * File extension is not taken in account for matching names

        :param requested_metrics: Dict of metrics requested for this agent.
        :param available_scripts: List of scripts found on this agent.
        :param scripts_path: Absolute path to the script directory.
        :return: Dict of metrics which have a script available.
        """

        metrics = {}

        for metric_name, metric_spec in requested_metrics.iteritems():

            found = False

            metric_script_type = metric_spec['type'].lower()

            # Search in scripts
            for script in available_scripts:

                if script.lower().split('.')[0] == metric_script_type:
                    metric_spec['script'] = "{0}/{1}".format(scripts_path, script)
                    metrics[metric_name] = metric_spec

                    found = True
                    break

            if not found:
                LOG.error("Requested metric script %s was not found in %s", metric_script_type, scripts_path)

        return metrics

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

    @staticmethod
    @log_steps
    def set_aws_region():
        """
        Set an environment variable AWS_DEFAULT_REGION with the name of the AWS Region got from instance metadata.
        :return: None
        """
        aws_region = utils.get_instance_metadata(data='meta-data/placement/')['availability-zone'][:-1]
        LOG.debug("AWS Region : %s", aws_region)

        os.environ["AWS_DEFAULT_REGION"] = aws_region

    @log_steps
    def run(self):
        """
        Run the agent.
        """

        LOG.info('New run of CloudWatch Agent')

        scripts_path = "{0}/metrics.d".format(os.path.dirname(os.path.realpath(__file__)))
        available_scripts = [f for f in os.listdir(scripts_path) if os.path.isfile(os.path.join(scripts_path, f))]

        LOG.debug("Found scripts : {0}".format(available_scripts))

        # Match requested metrics vs available scripts
        available_metrics = self.match_metrics(self.metrics, available_scripts, scripts_path)

        # Execute all matches
        cloudwatch_request = self.evaluate_metrics(available_metrics)
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
