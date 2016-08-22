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
  $main_script_name = $cloudwatch::params::main_script_name,
  $user             = $cloudwatch::params::user
){

  validate_absolute_path($cloudwatch::params::base_dir)

  include awscli

  # Local variables
  $metrics_path     = "$base_dir/$metrics_dir"
  $main_script_path = "$base_dir/$main_script_name"

  # Creates a system user if required
  user { $user :
    ensure  => 'present',
    comment => 'User for CloudWatch Agent'
  }

  # Creates base directory
  file { $base_dir :
    ensure => directory,
    mode   => '0755',
    owner  => "$user",
    group  => 'root',
  }

  # Copy metrics scripts
  notice("Install metrics : $metrics_path")

  file { $metrics_path :
    ensure  => directory,
    source  => 'puppet:///modules/cloudwatch/metrics.d',
    recurse => 'remote',
    mode    => '0744',
    owner   => $user,
    group   => 'root',
  }

  # Copy CloudWatch Agent main script
  notice("Install main script : $main_script_path")

  file { $main_script_path :
    ensure  => 'present',
    mode    => '0744',
    source  => 'puppet:///modules/cloudwatch/cloudwatch_agent.sh'
  }


}
