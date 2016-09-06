# Class: cloudwatch::config
# =========================
#
# Configure the CloudWatch Agent.
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
class cloudwatch::config {

  # Local variables
  $main_script_path        = "${cloudwatch::base_dir}/${cloudwatch::main_script_name}"
  $configuration_file_path = "${cloudwatch::base_dir}/${cloudwatch::configuration_file}"
  $metrics_file_path       = "${cloudwatch::base_dir}/${cloudwatch::metrics_file}"

  # Set the list of monitoring metrics
  file { $metrics_file_path:
    ensure  => present,
    content => inline_template('<%= scope["cloudwatch::metrics"].to_yaml %>'),
    require => File[$cloudwatch::base_dir],
  }

  # Set the CloudWatch namespace for this instance
  file { $configuration_file_path:
    ensure  => present,
    require => File[$cloudwatch::base_dir],
  } ->
  file_line { 'Set namespace':
    ensure => present,
    path   => $configuration_file_path,
    line   => "namespace: ${::t_subenv}-${::t_environment}",
    match  => '^namespace:',
  }

  #Set the CloudWatch Agent main script in Cron
  cron { 'CloudWatch Agent':
    command     => "flock -n 200 ${cloudwatch::base_dir}/venv/bin/python ${main_script_path} \
-c ${configuration_file_path} -m ${metrics_file_path} >/dev/null 2>&1",
    user        => $cloudwatch::user,
    minute      => '*/1',
    environment => ['HOME=/tmp', 'PATH=/usr/bin:/bin'],
    require     => File[$cloudwatch::base_dir],
  }
}
