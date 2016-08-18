# Class: cloudwatch::config
# =========================
#
# Configure the CloudWatch Agent.
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
class cloudwatch::config (

  $base_dir         = $cloudwatch::params::base_dir,
  $metrics_dir      = $cloudwatch::params::metrics_dir,
  $main_script_path = $cloudwatch::params::main_script_path,
  $user             = $cloudwatch::params::user
){

  #Set the CloudWatch Agent main script in Cron
  cron { 'cloudwatch_agent':
    command => "$main_script_path",
    user    => "$user",
    minute  => '*/1',
    require => File["$main_script_path"]
  }
}
