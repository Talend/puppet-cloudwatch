#
# Installs common_packages
#
class common::packages {

  ensure_packages({
    'virtualenv'   => { provider => 'pip', ensure => 'present'},
  })
}
