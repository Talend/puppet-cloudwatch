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
# None - Variables are set on the cloudwatch::params class.
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

) inherits cloudwatch::params {

  contain (cloudwatch::install, cloudwatch::config)
  Class['cloudwatch::install'] -> Class['cloudwatch::config']
}