source ENV['GEM_SOURCE'] || 'https://rubygems.org'

puppetversion = ENV.key?('PUPPET_VERSION') ? "#{ENV['PUPPET_VERSION']}" : ['>= 3.3']
gem 'metadata-json-lint'
gem 'puppet', '3.8'
gem 'puppetlabs_spec_helper', '>= 1.0.0'
gem 'puppet-lint', '>= 1.0.0'
gem 'facter', '>= 1.7.0'
gem 'rspec-puppet'
gem 'rspec-retry'
gem 'serverspec-aws-resources', :github => 'talend/serverspec-aws-resources'

# rspec must be v2 for ruby 1.8.7
if RUBY_VERSION >= '1.8.7' and RUBY_VERSION < '1.9'
  gem 'rspec', '~> 2.0'
end

group :system_tests do
  gem 'librarian-puppet'
  gem 'test-kitchen'
  gem 'kitchen-sync'
  gem 'kitchen-puppet'
  gem 'kitchen-vagrant'
end
