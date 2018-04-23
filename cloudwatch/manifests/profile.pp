# Class: cloudwatch::profile
# ==========================
#
# Profile for cloudwatch agent.
#
# Get a list of metrics from Hiera (key : cloudwatch::metrics) and provide it to the cloudwatch agent component.
#
# Variables
# ---------
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
class cloudwatch::profile {

  class { '::cloudwatch':
    metrics => hiera_hash('cloudwatch::metrics', {}),
  }
}
