#
# Installs hiera-defined common_packages
#
class common::packages {

  #require ::pip

  create_resources(
    Package,
    hiera_hash('common_packages', {})
  )

}
