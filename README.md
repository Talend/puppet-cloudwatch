# puppet-cloudwatch

#### Table of Contents

1. [Description](#description)
1. [Setup - The basics of getting started with cloudwatch](#setup)
    * [What cloudwatch affects](#what-cloudwatch-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with cloudwatch](#beginning-with-cloudwatch)
1. [Usage - Configuration options and additional functionality](#usage)
1. [Tests - How to run tests for this module](#tests)
1. [Reference - An under-the-hood peek at what the module is doing and how](#reference)


## Description

"puppet-cloudwatch" is a Puppet module providing a monitoring Agent running regularly to push metrics in AWS CloudWatch

## Setup

### What puppet-cloudwatch affects

Running puppet-cloudwatch will do the following things on the instance :

* A sub-folder is created to store all files related to the CloudWatch Agent
    * Default sub-folder : '/opt/cloudwatch-agent/'
* A script is set in Cron to run at a set interval all required metrics scripts
    * Default interval : every minutes
* A sub-folder is created to store logs produced by the CloudWatch Agent
    * Default sub-folder : '/var/log/cloudwatch-agent/'

### Setup Requirements

This module requires you to have access to AWS CloudWatch using a set of credentials.


### Beginning with puppet-cloudwatch

When using librarian-puppet : add this module to your Puppetfile using the code below.

```
mod 'talend/cloudwatch',
  :git  => 'git@github.com:Talend/puppet-cloudwatch.git'
```

The main class to include/require is "cloudwatch" : this class triggers the installation & configuration of the 
CloudWatch Agent as well as setting up the Cron job to run it.

## Usage

### Implementing a new metric

In order to implement a new monitoring metric you have to :

* Create a script in files/cloudwatch_agent/metrics.d that will be used by the agent to collect a metric value.
    * this script must print a numeric value (integer or float)
    * CloudWatch Agent expects a return code 0 from metric scripts to consider that the execution went well.
* Declare this metric in the relevant Hiera YAML file using the following format :

```yaml
cloudwatch::metrics:
    
  Metric name:
    type              : name of the script available in metrics.d on
                        instances (without file extention)
    params            : List of parameters to give to the script
                        between single quotes.
    unit              : CloudWatch unit
    description       : A small description of the metric
    statistic         : CloudWatch statistic applied to the metric value
    period            : Number in seconds (multiples of 60) over which
                        the statistic is applied
    evaluationperiods : Number of periods over which data is
                        compared to the threshold
    threshold         : Value against which the statistic is compared
    comparisonoperator: CloudWatch comparison operator
```

Note : unit, statistic, period, evaluationperiods, threshold & comparison operator are CloudWatch
concepts. Their value must match CloudWatch specifications (type of values, etc....).
See the reference below.

Example from hieradata/global.yaml :

```yaml
cloudwatch::metrics:
  DiskSpace:
    type              : diskspace
    params            : '-f /'
    unit              : Percent
    description       : 'Percentage of used disk space for root filesystem'
    statistic         : 'Average'
    period            : 300
    evaluationperiods : 10
    threshold         : 1000
    comparisonoperator: "GreaterThanThreshold"

  Memory:
    type              : memory
    params            : ''
    unit              : Megabytes
    description       : 'Memory available on the system in MB.'
    statistic         : 'Average'
    period            : 300
    evaluationperiods : 10
    threshold         : 1000
    comparisonoperator: "GreaterThanThreshold"
```

## Tests

There are several tests for puppet-cloudwatch :

* unit tests & acceptance tests for the Puppet module itself
* unit tests for the CloudWatch Agent

### Puppet module tests

Unit tests are using rspec : they test the content of the Puppet manifest after compiling.

Acceptance tests are using Kitchen (to launch either a local virtualbox or an EC2 instance) &
serverspec (to describe how the instance should look like after running Puppet).

* Launch unit tests :

```bash
bundle exec rake test
```

* Launch acceptance tests :

```bash
bundle exec rake kitchen:all
```

### CloudWatch Agent tests

Unit tests for the CloudWatch Agent can be run with the following command :

```bash
tox
```

These tests are using :

* tox : provide virtualenvs for each kind of tests & run them
* flake8 : syntaxic verifications (pep8)
* pytest : unit tests implemented in files/cloudwatch_agent/tests
    * pytest-capturelog : provide log capturing feature with an associated fixture
    * pytest-cov : coverage report for pytest
    * pytest-mock : provide a wrapper for Mock as fixture for tests

## Reference

1. [AWS CloudWatch Concepts](http://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/cloudwatch_concepts.html)