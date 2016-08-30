# Class: cloudwatch
# =================
#
# Main class of the puppet-cloudwatch module.
#
# Does the following :
#     * Install the CloudWatch Agent scripts
#     * Creates a configuration file for the agent
#     * Configure the agent to run through Cron
#
# Variables
# ---------
# * $base_dir         : Absolute path to the base directory where the CloudWatch Agent is installed
# * $metrics_dir      : Name of the directory storing metric scripts
# * $logs_path        : Absolute path the directory where logs are written
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
class cloudwatch (

  $base_dir         = $cloudwatch::params::base_dir,
  $metrics_dir      = $cloudwatch::params::metrics_dir,
  $logs_path        = $cloudwatch::params::logs_path,
  $main_script_name = $cloudwatch::params::main_script_name,
  $user             = $cloudwatch::params::user

) inherits cloudwatch::params {

  contain (::cloudwatch::install, ::cloudwatch::config)
  Class['cloudwatch::install'] -> Class['cloudwatch::config']
}