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
  $main_script_path = "${cloudwatch::base_dir}/${cloudwatch::main_script_name}"

  #Set the CloudWatch Agent main script in Cron
  cron { 'CloudWatch Agent':
    command => "${cloudwatch::base_dir}/venv/bin/python ${main_script_path} >/dev/null 2>&1",
    user    => $cloudwatch::user,
    minute  => '*/1',
    require => File[$main_script_path]
  }

  # TODO : extract configuration file from Hiera
}
