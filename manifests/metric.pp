# Defined Type: cloudwatch::metric
# ===========================
#
# Full description of type cloudwatch::metric here.
#
# Variables
# ----------
#
# Here you should define a list of variables that this module would require.
#
# * `metric_executable`
#    path to the metric runner script as erb template
#    default location would be something like 'cloudwatch/opt/talend/metrics.d/my_script.erb'
#
# Examples
# --------
#
# @example
#    define cloudwatch::metric { 'my_metric':
#      metric_executable => 'cloudwatch/opt/talend/metrics.d/my_script.erb',
#    }
#
# Authors
# -------
#
# Author Name <author@domain.com>
#
# Copyright
# ---------
#
# Copyright 2016 Your name here, unless otherwise noted.
define cloudwatch::metric (

  $aws_region               = hiera('aws-region', 'us-east-1'),
  $metric_executable        = undef,
  $alarm_enable             = false,
  $alarm_threshold          = undef,
  $alarm_statistic          = 'Average',
  $alarm_period             = '300',
  $alarm_evaluation_periods = '3',
  $alarm_comparison_operator= 'GreaterThanThreshold',
  $alarm_dimensions         = undef,
  $alarm_actions       = "arn:aws:automate:${aws_region}:ec2:recover"

) {

  if $metric_executable == undef {
    fail('ERROR: param metric_executable is unset. This value has to be defined ')
  }

  include cloudwatch

  file{"/opt/talend/cloudwatch/metrics.d/${name}_metric":
    ensure  => 'present',
    content => template($metric_executable),
    mode    => '0744',
    owner   => 'root',
    group   => 'root',
    require => File['/opt/talend/cloudwatch/metrics.d'],
  }

  if $alarm_enable {
    cloudwatch_alarm {$name:
      ensure              => present,
      metric              => $name,
      namespace           => $::puppet_role,
      statistic           => $alarm_statistic,
      period              => $alarm_period,
      evaluation_periods  => $alarm_evaluation_periods,
      threshold           => $alarm_threshold,
      comparison_operator => $alarm_comparison_operator,
      region              => $aws_region,
      dimensions          => $alarm_dimensions,
      alarm_actions        => $alarm_actions
    }
  }

}