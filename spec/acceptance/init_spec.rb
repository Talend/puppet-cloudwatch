require 'spec_helper_acceptance'

describe 'cloudwatch' do

  it_should_behave_like 'cloudwatch::installed', "
      metric_executable => 'cloudwatch/talend/example_sript.sh.erb',
      alarm_enable      => true,
      alarm_threshold   => 99,

  "

  it_should_behave_like 'cloudwatch::running'
end
