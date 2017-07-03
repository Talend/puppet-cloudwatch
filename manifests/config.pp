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
# Copyright 2017 Talend, unless otherwise noted.
#
class cloudwatch::config (
    $minute = $cloudwatch::params::minute,
) {

  ############
  # Defaults #
  ############

  File {
    owner  => $cloudwatch::user,
    group  => $cloudwatch::user,
    mode   => '0644',
  }

  # Local variables
  $main_script_path        = "${cloudwatch::base_dir}/${cloudwatch::main_script_name}"
  $metrics_file_path       = "${cloudwatch::base_dir}/${cloudwatch::metrics_file}"

  # Set the list of monitoring metrics
  file { $metrics_file_path:
    ensure  => present,
    content => inline_template('<%= {"metrics" => scope["cloudwatch::metrics"]}.to_yaml %>'),
    require => File[$cloudwatch::base_dir],
  }

  # Set a Cloudwatch namespace
  file_line { 'Set namespace':
    ensure => present,
    path   => $metrics_file_path,
    line   => "  namespace: ${cloudwatch::namespace}",
    match  => '^[[:space:]]*namespace:',
  }


  # Add "cloudwatch-agent" sudo rights (defined in Hiera) to existing sudoers.
  if ! defined(Class['::sudo']) {
    class { '::sudo':
      purge               => false,
      config_file_replace => false,
    }
  }

  include ::sudo::configs

  #Set the CloudWatch Agent main script in Cron
  cron { 'CloudWatch Agent':
    command     => "flock -n /tmp/cloudwatch-agent.lock ${cloudwatch::base_dir}/venv/bin/python ${main_script_path} \
--metrics ${metrics_file_path} >/dev/null 2>&1",
    user        => $cloudwatch::user,
    minute      => '*/${minute}',
    environment => ['HOME=/tmp', 'PATH=/usr/bin:/bin'],
    require     => File[$cloudwatch::base_dir],
  }
}
