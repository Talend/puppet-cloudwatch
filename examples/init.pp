# file for local tests
File { backup => false }

file { '/root/.aws':
  ensure => directory,
} ->
file { '/root/.aws/credentials':
  content =>  "
[default]
aws_access_key_id = ${::aws_api_key}
aws_secret_access_key = ${::aws_secret_access_key}
"
} ->
file { '/root/.aws/config':
  content =>  "
[default]
region=eu-west-1
output=json
"
} ->
package { 'aws-sdk-core':
  ensure   => installed,
  provider => 'gem',
} ->
package { 'retries':
  ensure   => installed,
  provider => 'gem',
} ->
class { '::cloudwatch': }
