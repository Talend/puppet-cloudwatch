# Class: cloudwatch::config
# =========================
#
# Configure the CloudWatch Agent.
#
# Variables
# ----------
# None - Variables should be set on the cloudwatch::params class.
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
class cloudwatch::config (

  $base_dir         = $cloudwatch::params::base_dir,
  $metrics_dir      = $cloudwatch::params::metrics_dir,
  $main_script_name = $cloudwatch::params::main_script_name,
  $user             = $cloudwatch::params::user


){

  # Local variables
  $main_script_path = "${base_dir}/${main_script_name}"

  #Set the CloudWatch Agent main script in Cron
  cron { 'CloudWatch Agent':
    command => "${base_dir}/venv/bin/python ${main_script_path} >/dev/null 2>&1",
    user    => $user,
    minute  => '*/1',
    require => File[$main_script_path]
  }

  # TODO : extract configuration file from Hiera
}
