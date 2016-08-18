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
class cloudwatch::install (

  $base_dir         = $cloudwatch::params::base_dir,
  $metrics_dir      = $cloudwatch::params::metrics_dir,
  $main_script_path = $cloudwatch::params::main_script_path,
  $user             = $cloudwatch::params::user
){

  validate_absolute_path($cloudwatch::params::base_dir)

  include awscli

  # Creates a system user if required
  user { "$user":
    ensure  => 'present',
    comment => 'User for CloudWatch Agent'
  }

  # Directories used by the CloudWatch Agent
  $cloudwatch_agent_dirs = [
    "$base_dir",
    "$metrics_dir"
  ]

  # Creates required directories
  file { $cloudwatch_agent_dirs:
    ensure => directory,
    mode   => '0755',
    owner  => "$user",
    group  => 'root',
  }

  # Copy CloudWatch Agent main script
  file { "$main_script_path" :
    ensure  => 'present',
    mode    => '0744',
    source  => '../files/cloudwatch_agent.sh'
  }

  # Copy metrics scripts
  file { "$metrics_dir":
    ensure  => 'directory',
    source  => '../files/metric.d',
    recurse => 'remote',
    mode    => '0744',
    owner   => "$user",
    group   => 'root',
  }
}
