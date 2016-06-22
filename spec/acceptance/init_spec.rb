require 'spec_helper_acceptance'

describe 'cloudwatch' do

  it_should_behave_like 'cloudwatch::installed', "
      metric_executable => 'cloudwatch/talend/example_sript.sh.erb'
  "

  it_should_behave_like 'cloudwatch::running'
end
