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

  ###################
  # Local Variables #
  ###################

  $metrics_path       = "${cloudwatch::base_dir}/${cloudwatch::metrics_dir}"
  $main_script_path   = "${cloudwatch::base_dir}/${cloudwatch::main_script_name}"
  $configuration_path = "${cloudwatch::base_dir}/configuration.yaml"
  $pip_requirements   = "${cloudwatch::base_dir}/requirements.txt"

  ############################
  # Install system resources #
  ############################

  validate_absolute_path($cloudwatch::base_dir)

  # Creates a system user if required
  user { $cloudwatch::user :
    ensure  => 'present',
    comment => 'User for CloudWatch Agent'
  }

  # Get Python dependencies for cloudwatch-agent
  file { $pip_requirements :
    ensure => 'present',
    mode   => '0744',
    source => 'puppet:///modules/cloudwatch/requirements.txt',
    owner  => $cloudwatch::user,
  }

  # Manage Third Party tools
  class { 'python':
    version    => system,
    pip        => present,
    virtualenv => present,
    dev        => present
  }
  -> class { 'awscli': }

  # Set a dedicated virtual env with requirements
  python::virtualenv { "${cloudwatch::base_dir}/venv":
    ensure       => present,
    version      => system,
    requirements => $pip_requirements,
    venv_dir     => "${cloudwatch::base_dir}/venv",
    owner        => $cloudwatch::user,
  }

  ###############################
  # Copy CloudWatch-Agent files #
  ###############################

  # Creates base directory
  file { $cloudwatch::base_dir :
    ensure => directory,
    mode   => '0755',
    owner  => $cloudwatch::user,
  }

  # Copy metrics scripts
  file { $metrics_path :
    ensure  => directory,
    source  => 'puppet:///modules/cloudwatch/metrics.d',
    recurse => remote,
    mode    => '0744',
    owner   => $cloudwatch::user,
  }

  # Copy CloudWatch Agent main script
  file { $main_script_path :
    ensure => file,
    mode   => '0744',
    source => "puppet:///modules/cloudwatch/${cloudwatch::main_script_name}",
    owner  => $cloudwatch::user,
  }

  # Copy configuration file template
  file { $configuration_path :
    ensure => file,
    mode   => '0744',
    source => 'puppet:///modules/cloudwatch/configuration.yaml',
    owner  => $cloudwatch::user,
  }

  # Bootstrap CloudWatch Agent logs
  file { $cloudwatch::logs_path :
    ensure => directory,
    mode   => '0744',
    owner  => $cloudwatch::user,
  }
}
