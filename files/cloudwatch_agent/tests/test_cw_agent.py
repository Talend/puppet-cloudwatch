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
    script_path = '/test/metrics.d'

    default_float_value = 42.0
    default_dimension_value = 'FakeValue'
    default_test_aws_region = 'test-region-3c'

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

        test_instance_userdata = {'cloud_formation': {'ecs_cluster_name': 'test_cluster'},
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

    @pytest.fixture()
    def expected_dimensions(self, good_agent):
        """
        Provide a test set of expected dimensions for get_metric_dimensions().

        :return: Test set as a list of dict :
                    * Name of the dimension
                    * Fake value for this dimension
        """

        return [{'Name': 'InstanceID',
                 'Value': good_agent.instance_id},
                {'Name': 'ImplementedDimension',
                 'Value': self.default_dimension_value}]

    @pytest.fixture()
    def expected_metrics(self):
        """
        Provide a test set of expected metrics for match_metrics().

        :return: Test set :
                    * all metrics from test_metrics.yaml
                    * except the NumberOfRunningContainers (left behind for testing the bahaviour of the agent)
                    * enriched with the metric script path
        """

        expected_metrics = self.metrics['metrics'].copy()
        del expected_metrics['NumberOfRunningContainers']

        for _, metric_spec in expected_metrics.iteritems():
            metric_spec['script'] = "{0}/{1}".format(self.script_path, metric_spec['type'])

        return expected_metrics

    @pytest.fixture()
    def expected_results(self):
        """
        Provide a test set of expected results for evaluate_metrics():

        Test set :
        * Cloudwatch Data format for all metrics from test_metrics.yaml
        """

        return [{'Unit': 'Percent',
                 'MetricName': 'DiskSpace',
                 'Value': 42.0,
                 'Dimensions': [{'Value': 'fake-instance-id', 'Name': 'InstanceID'}]},
                {'Unit': 'Count',
                 'MetricName': 'NumberOfRunningContainers',
                 'Value': 42.0,
                 'Dimensions': [{'Value': 'fake-instance-id', 'Name': 'InstanceID'}]},
                {'Unit': 'Count',
                 'MetricName': 'NumberOfRunningContainers',
                 'Value': 42.0,
                 'Dimensions': [{'Value': u'test_cluster', 'Name': 'ECSCluster'}]},
                {'Unit': 'Megabytes',
                 'MetricName': 'Memory',
                 'Value': 42.0,
                 'Dimensions': [{'Value': 'fake-instance-id', 'Name': 'InstanceID'}]
                 }
                ]

    # ----------
    # Unit tests
    # ----------

    def test_evaluate_metrics(self, good_agent, caplog, mocker, expected_results):
        """
        Test the evaluate_metrics() method.

        :param good_agent: CloudWatch Agent (provided by local fixture)
        :param caplog: Capture log (provided by pytest-capturelog fixture)
        :param mocker: Mock wrapper (provided by pytest-mock fixture)
        :param expected_results: Test set of expected results (provided by local fixture)
        """

        # Mock subprocess.Popen() & stuff
        mocked_subprocess = mocker.patch.object(subprocess, 'Popen', autospec=True)

        good_process_mock = mocker.Mock()
        good_attrs = {'communicate.return_value': ('42', 'error'),
                      'returncode': 0}
        good_process_mock.configure_mock(**good_attrs)

        mocked_subprocess.return_value = good_process_mock

        # Prepare test metrics
        metrics = self.metrics['metrics'].copy()

        for _, metric_spec in metrics.iteritems():
            metric_spec['script'] = "{0}/{1}".format(self.script_path, metric_spec['type'])

        evaluated_results = good_agent.evaluate_metrics(metrics)

        # Check evaluated results
        for result in evaluated_results:
            assert result in expected_results

    def test_match_metrics(self, good_agent, caplog, expected_metrics):
        """
        Test the match_metrics() method :
        * some requested metrics are matched : they must be enriched
        * some requested metrics are left unmatched : expecting an error message in logging.

        :param good_agent: CloudWatch Agent (provided by local fixture)
        :param caplog: Capture log (provided by pytest-capturelog fixture)
        :param expected_metrics: Test set of expected metrics (provided by local fixture)
        """

        # Leave "NumberOfRunningContainers / dockerinfo" metric behind
        available_metrics = good_agent.match_metrics(good_agent.metrics, ['diskspace', 'memory'], self.script_path)

        # Check not found metrics (as log messages)
        assert [record
                for record
                in caplog.records
                if record.levelname == 'ERROR'
                and 'dockerinfo' in record.message]

        # Check found metrics
        for metric in available_metrics:
            assert metric in expected_metrics

    def test_get_metric_dimensions(self, good_agent, caplog, mocker, expected_dimensions):
        """
        Test get_metric_dimensions() method.

        Test one implemented dimension & one unimplemented.

        :param good_agent: CloudWatch Agent (provided by local fixture)
        :param caplog: Capture log (provided by pytest-capturelog fixture)
        :param mocker: Mock wrapper (provided by pytest-mock fixture)
        :param expected_dimensions: Test set of expected dimensions (provided by local fixture)
        """

        # Fake the implementation of 'ImplementedDimension'
        def get_dimension_ImplementedDimension():
            return {'Name': 'ImplementedDimension', 'Value': self.default_dimension_value}

        good_agent.get_dimension_ImplementedDimension = get_dimension_ImplementedDimension

        LOG.info("Agent : %s", dir(good_agent))

        requested_dimensions = ['ImplementedDimension', 'UnimplementedDimension']
        evaluated_dimensions = good_agent.get_metric_dimensions(requested_dimensions)

        # Check unevaluated dimensions (as log messages)
        assert [record
                for record
                in caplog.records
                if record.levelname == 'ERROR'
                and 'Dimension UnimplementedDimension is not implemented in the CloudWatch Agent' in record.message]

        # Check evaluated dimensions
        for dimension in evaluated_dimensions:
            assert dimension in expected_dimensions

    def test_get_dimension_ECSCluster(self, good_agent):
        """
        Test the get_dimension_ECSCluster() method.

        :param good_agent: CloudWatch Agent (provided by local fixture)
        """
        dimension = good_agent.get_dimension_ECSCluster()
        expected = {'Name': 'ECSCluster', 'Value': 'test_cluster'}

        assert dimension == expected

    def test_push_cloudwatch(self, good_agent, caplog):
        """
        Test the push_cloudwatch() method.

        Test with either a regular request and an empty one.

        Note : the AWS CloudWatch client is already mocked in the CWAgent used for tests (good_agent).

        :param good_agent: CloudWatch Agent (provided by local fixture)
        :param caplog: Capture log (provided by pytest-capturelog fixture)
        """

        fake_request = 'FakeRequest'

        good_agent.push_cloudwatch(fake_request)

        # Check that put_metric_data was called
        good_agent.cloudwatch.put_metric_data.assert_called_once_with(Namespace=good_agent.namespace,
                                                                      MetricData=fake_request)

        # Check error message in case of wrong request
        good_agent.push_cloudwatch('')
        assert [record
                for record
                in caplog.records
                if record.levelname == 'ERROR'
                and 'No metrics data to send !' in record.message]

    def test_set_aws_region(self, good_agent, mocker):
        """
        Test the set_aws_region() method.

        :param good_agent: CloudWatch Agent (provided by local fixture)
        :param mocker: Mock wrapper (provided by pytest-mock fixture)
        """

        # Mock the instance metadata
        mocked_metadata = mocker.patch.object(utils, 'get_instance_metadata')
        mocked_metadata.return_value = {'availability-zone': self.default_test_aws_region}

        good_agent.set_aws_region()

        # Check environment variable
        assert os.environ["AWS_DEFAULT_REGION"] == self.default_test_aws_region[:-1]

    def test_run(self, good_agent, mocker):
        """
        Test the run() method.

        :param good_agent: CloudWatch Agent (provided by local fixture)
        :param mocker: Mock wrapper (provided by pytest-mock fixture)
        """

        # Mock external method calls
        os = mocker.MagicMock()
        os.listdir.return_value = ['memory.sh']
        os.path.isfile.return_value = True
        os.path.dirname.return_value = '/test'

        # Mock internal method calls
        good_agent.match_metrics = mocker.MagicMock()
        good_agent.evaluate_metrics = mocker.MagicMock()
        good_agent.push_cloudwatch = mocker.MagicMock()

        good_agent.run()

        # Check that calls were made
        good_agent.match_metrics.assert_called_once()
        good_agent.evaluate_metrics.assert_called_once()
        good_agent.push_cloudwatch.assert_called_once()
