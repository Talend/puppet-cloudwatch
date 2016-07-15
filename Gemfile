source 'http://rubygems.org'

gem 'puppet', '~> 3.8'
gem 'rake'

group :test do
  gem 'metadata-json-lint'
  gem 'puppetlabs_spec_helper'
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
end
