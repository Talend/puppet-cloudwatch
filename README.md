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
    * Default sub-folder : '/opt/talend/cloudwatch/'
* A script is set in Cron to run at a set interval all required metrics scripts
    * Default interval : every minutes
    * Default script name : cloudwatch_agent.sh

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

TO DO : explain how to implement a new metric.

## Reference

TO DO : provide code documentation here