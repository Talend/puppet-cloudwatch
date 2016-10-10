#!/usr/bin/env python
# coding: utf8

"""
Test suite for the CloudWatch Agent.

Uses the following tools :
* pytest : test framework
* mock : to mock boto & other external dependencies
* pytest-mock : wrapper to provide mock API in pytest through the "mocker" fixture
* pytest-catchlog : catches all output (logs, stdout & stderr) from tests and display them in test results.
"""

import boto3
from boto import utils

import json
import logging
import os
import pytest
import subprocess
import yaml

from ..cw_agent import CWAgent

# ---------
# Constants
# ---------

SCRIPT_DIR = os.path.dirname(os.path.realpath(__file__))
TEST_METRICS_FILE = "{0}/test_metrics.yaml".format(SCRIPT_DIR)
LOG = logging.getLogger(__name__)


class TestCWAgent(object):
    """
    Test class dedicated to the CloudWatch Agent
    """

    metrics = yaml.load(open(TEST_METRICS_FILE))

    # -----------------------
    # Fixtures for unit tests
    # -----------------------

    @pytest.fixture()
    def good_agent(self, mocker):
        """
        Provide a CloudWatch Agent to tests

        :return: CWAgent object
        """

        # Mock boto3 calls on the agent init
        mocker.patch.object(boto3, 'client', autospec=True)

        # Provide test values from boto.utils in agent init
        mocked_metadata = mocker.patch.object(utils, 'get_instance_metadata')
        mocked_metadata.return_value = {'availability-zone': 'us-east-1a',
                                        'instance-id': 'fake-instance-id'}

        mocked_userdata = mocker.patch.object(utils, 'get_instance_userdata')

        test_instance_userdata = {'cloud_formation':
                                      {'ecs_cluster_name': 'test_cluster'},
                                  't_facts': {
                                      't_dc': 'aws-us-east-1',
                                      't_role': 'ecs-resource',
                                      't_profile': 'ci',
                                      't_subenv': 'sharedecs',
                                      't_branch': 'trunk',
                                      't_environment': 'dv',
                                      't_release': 'trunk'}
                                  }

        mocked_userdata.return_value = json.dumps(test_instance_userdata)

        return CWAgent(self.metrics)

    # ----------
    # Unit tests
    # ----------

    """
    def test_evaluate_metrics(self, good_agent, caplog, mocker):

        Test the evaluate_metrics() method.

        :param good_agent: CloudWatch Agent (provided by local fixture)
        :param caplog: Capture log (provided by pytest-capturelog fixture)


        # Mock subprocess.Popen()
        mocked_subprocess = mocker.patch.object(subprocess, 'Popen', autospec=True)

        evaluated_metrics = good_agent.evaluate_metrics()
    """

    def test_match_metrics(self, good_agent, caplog):
        """
        Test the match_metrics() method :
        * some requested metrics are matched : they must be enriched
        * some requested metrics are left unmatched : expecting an error message in logging.

        :param good_agent: CloudWatch Agent (provided by local fixture)
        :param caplog: Capture log (provided by pytest-capturelog fixture)
        """
        script_path = '/test/metrics.d'

        # Leave "NumberOfRunningContainers / dockerinfo" metric behind
        available_metrics = good_agent.match_metrics(good_agent.metrics, ['diskspace', 'memory'], script_path)

        expected_metrics = self.metrics['metrics'].copy()
        del expected_metrics['NumberOfRunningContainers']

        for _, metric_spec in expected_metrics.iteritems():
            metric_spec['script'] = "{0}/{1}".format(script_path, metric_spec['type'])

        # Search for an ERROR message for dockerinfo metric
        assert [record
                for record
                in caplog.records
                if record.levelname == 'ERROR'
                and 'dockerinfo' in record.message]

        assert available_metrics == expected_metrics

    def test_get_dimension_ECSCluster(self, good_agent):
        """
        Test the get_dimension_ECSCluster() method.

        :param good_agent: CWAgent provided through fixture.
        """
        dimension = good_agent.get_dimension_ECSCluster()
        expected = {'Name': 'ECSCluster', 'Value': 'test_cluster'}

        assert dimension == expected

    """
    def test_evaluate_metrics(self):
        assert 1== 1

    def test_get_metric_dimensions(self):
        assert 1== 1



    test_push_cloudwatch

    test_set_aws_region

    test_run
    """
