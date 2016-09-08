# puppet-cloudwatch

#### Table of Contents

1. [Description](#description)
1. [Setup - The basics of getting started with cloudwatch](#setup)
    * [What cloudwatch affects](#what-cloudwatch-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with cloudwatch](#beginning-with-cloudwatch)
1. [Usage - Configuration options and additional functionality](#usage)
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
* A sub-folder is created to store logs produec by the CloudWatch Agent
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
  - name   : <must match the name of your script without file extension (case insensitive)>
    params : '<arguments & options you want to provide to your script'
    unit   : <Unit name from the allowed list of units in CloudWatch. See reference below.>
```

## Reference

1. [AWS CloudWatch Metric reference](http://docs.aws.amazon.com/AmazonCloudWatch/latest/APIReference/API_MetricDatum.html)