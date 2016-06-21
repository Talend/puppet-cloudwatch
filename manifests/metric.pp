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

  $metric_executable = undef

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

}