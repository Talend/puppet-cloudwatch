#
# Installs common_packages
#
class common::packages {

  ensure_packages({
    'epel-release' => {ensure => 'present'},
    'python2-pip'  => { ensure => 'present', require => Package['epel-release']},
    'virtualenv' => {provider => 'pip', ensure => 'present'}
  })

}
