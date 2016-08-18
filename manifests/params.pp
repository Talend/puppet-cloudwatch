# Class: cloudwatch::params
# =========================
#
# Stores parameters for the cloudwatch module.
#
# Variables
# ----------
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
class cloudwatch::params {

  $base_dir         = '/opt/cloudwatch-agent'
  $metrics_dir      = "$base_dir/metrics.d",
  $bin_dir          = "$base_dir/bin",
  $main_script_path = "$bin_dir/cloudwatch_agent.sh",
}