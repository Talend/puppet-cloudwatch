# Class: cloudwatch
# ===========================
#
# Full description of class cloudwatch here.
#
# Variables
# ----------
#
# Here you should define a list of variables that this module would require.
#
# * `sample variable`
#  Explanation of how this variable affects the function of this class and if
#  it has a default. e.g. "The parameter enc_ntp_servers must be set by the
#  External Node Classifier as a comma separated list of hostnames." (Note,
#  global variables should be avoided in favor of class parameters as
#  of Puppet 2.6.)
#
# Examples
# --------
#
# @example
#    class { 'cloudwatch': }
#
# Authors
# -------
#
# Author Name <andreas.heumaier@nordcloud.com>
#
# Copyright
# ---------
#
# Copyright 2016 Talend, unless otherwise noted.
#
class cloudwatch (

  $metrics_namespace = 'Talend'
  $metrics_path      = '/opt/talend/cloudwatch/metrics.d',

){

  validate_absolute_path($metrics_path)

  include awscli

  file { ['/opt/talend','/opt/talend/cloudwatch', '/opt/talend/cloudwatch/metrics.d']:
    ensure => directory,
    mode   => '0755',
    owner  => 'root',
    group  => 'root',
  }

  file { '/usr/local/bin/send_metrics':
    ensure  => 'present',
    mode    => '0744',
    content => template('cloudwatch/talend/send_metrics.sh.erb')
  }

  cron { 'cloudwatch_metrics':
    command => '/usr/local/bin/send_metrics',
    user    => 'root',
    minute  => '*/1',
  }

}
