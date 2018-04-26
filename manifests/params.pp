# Class: cloudwatch::params
# =========================
#
# Stores parameters for the cloudwatch module.
#
# Variables
# ---------
# * $base_dir           : Absolute path to the base directory where the CloudWatch Agent is installed
# * $metrics_dir        : Name of the directory storing metric scripts
# * $logs_path          : Absolute path the directory where logs are written
# * $main_script_name   : Name of the CloudWatch Agent main script
# * $user               : Name of the user which executes the CloudWatch Agent
# * $configuration_file : Name of the configuration file used by the CloudWatch Agent
# * $metrics            : List of Cloudwatch metrics provisioned for the node
# * $namespace          : Cloudwatch namespace used to push this node's metrics
#
# Authors
# -------
#
# Talend DevOps Team
#
# Copyright
# ---------
#
# Copyright 2017 Talend.
#
class cloudwatch::params {

  $base_dir           = '/opt/cloudwatch-agent'
  $metrics_dir        = 'metrics.d'
  $logs_path          = '/var/log/cloudwatch-agent'
  $main_script_name   = 'cw_agent.py'
  $user               = 'cloudwatch-agent'
  $configuration_file = 'configuration.yaml'
  $metrics_file       = 'metrics.yaml'
  $metrics            = []
  $namespace          = ''

}
