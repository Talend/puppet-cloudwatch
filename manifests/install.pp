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
# Copyright 2017 Talend, unless otherwise noted.
#
class cloudwatch::install {

  ###################
  # Local Variables #
  ###################

  $metrics_path       = "${cloudwatch::base_dir}/${cloudwatch::metrics_dir}"
  $main_script_path   = "${cloudwatch::base_dir}/${cloudwatch::main_script_name}"
  $pip_requirements   = "${cloudwatch::base_dir}/requirements.txt"

  ############
  # Defaults #
  ############

  File {
    owner  => $cloudwatch::user,
    group  => $cloudwatch::user,
    mode   => '0744',
  }

  ############################
  # Install system resources #
  ############################

  validate_absolute_path($cloudwatch::base_dir)

  # Creates a system user if required
  user { $cloudwatch::user :
    ensure  => 'present',
    comment => 'User for CloudWatch Agent',
  }

  ###############################
  # Copy CloudWatch-Agent files #
  ###############################

  # Creates base directory
  file { $cloudwatch::base_dir :
    ensure  => directory,
    mode    => '0755',
    source  => 'puppet:///modules/cloudwatch/cloudwatch_agent/',
    recurse => remote,
  }

  file { $pip_requirements :
    ensure => 'present',
    source => 'puppet:///modules/cloudwatch/cloudwatch_agent/requirements.txt',
  }

  # Set a dedicated virtual env with requirements
  exec { 'ensure vitualenv created before doing any pip updates':
    command => "virtualenv ${cloudwatch::base_dir}/venv",
    path    => ["/bin", "/usr/bin", "/usr/local/bin"],
    creates => "${cloudwatch::base_dir}/venv",
    require => Class['::python'],
  } ->
  exec { 'ensure pip updated before doing any other pip updates':
    command => "${cloudwatch::base_dir}/venv/bin/pip install --upgrade pip && /bin/touch /var/tmp/pip_update.lock",
    creates => '/var/tmp/pip_update.lock',
  } ->
  exec { 'chown for cloudwatch::base_dir':
    command => "/usr/bin/chown -R ${$cloudwatch::user}:${$cloudwatch::user} ${cloudwatch::base_dir}",
    require => User[$cloudwatch::user],
  } ->
  python::virtualenv { "${cloudwatch::base_dir}/venv":
    ensure       => present,
    version      => system,
    requirements => $pip_requirements,
    venv_dir     => "${cloudwatch::base_dir}/venv",
    owner        => $cloudwatch::user,
    group        => $cloudwatch::user,
    require      => [File[$cloudwatch::base_dir], File[$pip_requirements]],
  }

  # Bootstrap CloudWatch Agent logs
  file { $cloudwatch::logs_path :
    ensure => directory,
    mode   => '0755',
  }

}
