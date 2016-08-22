# Class: cloudwatch::params
# =========================
#
# Stores parameters for the cloudwatch module.
#
# Variables
# ---------
# * $base_dir         : Absolute path to the base directory where the CloudWatch Agent is installed
# * $metrics_dir      : Name of the directory storing metric scripts
# * $main_script_name : Name of the CloudWatch Agent main script
# * $user             : Name of the user which executes the CloudWatch Agent
#
# Authors
# -------
#
# Talend DevOps Team
#
# Copyright
# ---------
#
# Copyright 2016 Talend, unless otherwise noted.
#
class cloudwatch::params (
  $base_dir         = '/opt/cloudwatch-agent',
  $metrics_dir      = "metrics.d",
  $main_script_name = "cloudwatch_agent.sh",
  $user             = 'cloudwatch-agent'
)
{}