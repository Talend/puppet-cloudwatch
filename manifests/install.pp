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
  $logs_path        = $cloudwatch::params::logs_path,
  $main_script_name = $cloudwatch::params::main_script_name,
  $user             = $cloudwatch::params::user
){

  validate_absolute_path($cloudwatch::params::base_dir)

  include awscli

  # Local variables
  $metrics_path     = "${base_dir}/${metrics_dir}"
  $main_script_path = "${base_dir}/${main_script_name}"
  $pip_requirements = "${base_dir}/requirements.txt"

  # Set resource defaults
  Exec {
    path => '/usr/bon:/bin:/usr/sbin:/sbin'
  }

  # Creates a system user if required
  user { $user :
    ensure  => 'present',
    comment => 'User for CloudWatch Agent'
  }

  # Creates base directory
  file { $base_dir :
    ensure => directory,
    mode   => '0755',
    owner  => $user,
    group  => 'root'
  }

  # Copy metrics scripts
  file { $metrics_path :
    ensure  => directory,
    source  => 'puppet:///modules/cloudwatch/metrics.d',
    recurse => 'remote',
    mode    => '0744',
    owner   => $user,
    group   => 'root'
  }

  # Copy CloudWatch Agent main script
  file { $main_script_path :
    ensure => 'present',
    mode   => '0744',
    source => 'puppet:///modules/cloudwatch/cloudwatch_agent.py',
    owner  => $user,
    group  => 'root'
  }

  # Bootstrap CloudWatch Agent logs
  file { $logs_path :
    ensure => directory,
    mode   => '0744',
    owner  => $user,
    group  => 'root'
  }

  # Get Python dependencies for cloudwatch-agent
  file { $pip_requirements :
    ensure => 'present',
    mode   => '0744',
    source => 'puppet:///modules/cloudwatch/requirements.txt',
    owner  => $user,
    group  => 'root'
  }

  # Get Virtualenv, create one & get requirements
  ensure_packages('virtualenv',
                    { ensure => 'present',
                      provider => 'pip'})

  exec { 'Create virtualenv':
    command => "virtualenv ${base_dir}/venv",
    user    => $user,
    require => Package[virtualenv]
  }

  exec { 'Install requirements':
    command => "${base_dir}/venv/bin/pip install -r ${pip_requirements}",
    user    => $user
  }
}
