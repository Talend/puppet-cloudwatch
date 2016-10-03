#!/usr/bin/env python
# coding: utf8

"""
Test suite for the CLoudWatch Agent.

Uses the following tools :
* pytest : test framework
* mock : to mock boto & other external dependencies
* pytest-mock : wrapper to provide mock API in pytest through the "mocker" fixture
"""

import boto3
from boto import utils

import json
import logging
import os
import pytest
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

    def test_get_dimension_ECSCluster(self, good_agent):
        """
        Test the get_dimension_ECSCluster() method.

        :param good_agent:
        """
        dimension = good_agent.get_dimension_ECSCluster()
        expected = {'Name': 'ECSCluster', 'Value': 'test_cluster'}

        assert dimension == expected
