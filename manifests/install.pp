# Class: cloudwatch::install
# ==========================
#
# Install the CloudWatch Agent.
#
# Variables
# ----------
# None
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
class cloudwatch::install {

  validate_absolute_path($cloudwatch::base_dir)

  include awscli

  # Local variables
  $metrics_path     = "${cloudwatch::base_dir}/${cloudwatch::metrics_dir}"
  $main_script_path = "${cloudwatch::base_dir}/${cloudwatch::main_script_name}"
  $pip_requirements = "${cloudwatch::base_dir}/requirements.txt"

  # Set resource defaults
  Exec {
    path => '/usr/bon:/bin:/usr/sbin:/sbin'
  }

  # Creates a system user if required
  user { $cloudwatch::user :
    ensure  => 'present',
    comment => 'User for CloudWatch Agent'
  }

  # Creates base directory
  file { $cloudwatch::base_dir :
    ensure => directory,
    mode   => '0755',
    owner  => $cloudwatch::user,
    group  => 'root'
  }

  # Copy metrics scripts
  file { $metrics_path :
    ensure  => directory,
    source  => 'puppet:///modules/cloudwatch/metrics.d',
    recurse => 'remote',
    mode    => '0744',
    owner   => $cloudwatch::user,
    group   => 'root'
  }

  # Copy CloudWatch Agent main script
  file { $main_script_path :
    ensure => 'present',
    mode   => '0744',
    source => 'puppet:///modules/cloudwatch/cloudwatch_agent.py',
    owner  => $cloudwatch::user,
    group  => 'root'
  }

  # Bootstrap CloudWatch Agent logs
  file { $cloudwatch::logs_path :
    ensure => directory,
    mode   => '0744',
    owner  => $cloudwatch::user,
    group  => 'root'
  }

  # Get Python dependencies for cloudwatch-agent
  file { $pip_requirements :
    ensure => 'present',
    mode   => '0744',
    source => 'puppet:///modules/cloudwatch/requirements.txt',
    owner  => $cloudwatch::user,
    group  => 'root'
  }

  # Get Virtualenv, create one & install requirements
  ensure_packages('virtualenv',
                    { ensure   => 'present',
                      provider => 'pip',
                      require  => Package['python-pip']})

  exec { 'Create virtualenv':
    command => "virtualenv ${cloudwatch::base_dir}/venv",
    user    => $cloudwatch::user,
    require => Package['virtualenv']
  }

  exec { 'Install requirements':
    command => "${cloudwatch::base_dir}/venv/bin/pip install -r ${pip_requirements}",
    user    => $cloudwatch::user,
    require => Exec['Create virtualenv']
  }
}
