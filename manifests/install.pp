# Class: cloudwatch::install
# ==========================
#
# Install the CloudWatch Agent.
#
# Variables
# ----------
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
class cloudwatch-agent::install (

  $base_dir         = $cloudwatch::params::base_dir,
  $metrics_dir      = $cloudwatch::params::metrics_dir,
  $bin_dir          = $cloudwatch::params::bin_dir,
  $main_script_path = $cloudwatch::params::main_script_path
){

  validate_absolute_path($cloudwatch::params::base_dir)

  include awscli

  # Directories used by the CloudWatch Agent
  $cloudwatch_agent_dirs = [
    "$base_dir",
    "$metrics_dir",
    "$bin_dir"
  ]

  file { $cloudwatch_agent_dirs:
    ensure => directory,
    mode   => '0755',
    owner  => 'root',
    group  => 'root',
  }

  file { "$main_script_path" :
    ensure  => 'present',
    mode    => '0744',
    content => template('cloudwatch/talend/cloudwatch_agent.sh.erb')
  }

  cron { 'cloudwatch_agent':
    command => "$main_script_path",
    user    => 'root',
    minute  => '*/1',
  }

  file { "/opt/talend/cloudwatch/metrics.d/${name}":
    ensure  => 'present',
    content => template($metric_executable),
    mode    => '0744',
    owner   => 'root',
    group   => 'root',
    require => File["$cloudwatch::params::metrics_path"],
  }


}
