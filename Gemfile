source 'http://rubygems.org'

gem 'puppet', '~> 3.8'
gem 'rake'

group :test do
  gem 'metadata-json-lint'
  gem 'puppetlabs_spec_helper'
  gem "rspec"
  gem "rspec-puppet", :git => 'https://github.com/rodjek/rspec-puppet.git'
  gem "rspec-puppet-facts"
  gem 'rubocop', '0.33.0'
  gem 'simplecov', '>= 0.11.0'
  gem 'simplecov-console'
  gem "puppet-lint-absolute_classname-check"
  gem "puppet-lint-leading_zero-check"
  gem "puppet-lint-trailing_comma-check"
  gem "puppet-lint-version_comparison-check"
  gem "puppet-lint-classes_and_types_beginning_with_digits-check"
  gem "puppet-lint-unquoted_string-check"
  gem 'puppet-lint-resource_reference_syntax'
end

group :development do
  gem 'vagrant-wrapper'
  gem 'kitchen-vagrant'
end

group :system_tests do
  gem 'librarian-puppet'
  gem 'test-kitchen'
  gem 'kitchen-puppet'
  gem 'kitchen-sync'
  gem 'kitchen-verifier-serverspec'
  gem 'net-ssh'
  gem 'serverspec'
  gem 'rspec_junit_formatter'
end
