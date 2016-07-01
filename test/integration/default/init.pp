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
class { 'cloudwatch':
  metrics_namespace => 'Testing',
} ->
cloudwatch::metric { 'DiskPercentage':
  aws_region        => 'eu-west-1',
  metric_executable => 'cloudwatch/talend/example_sript.sh.erb',
  alarm_enable      => false, # we do not want to call AWS APIs
  alarm_threshold   => 99,
}
