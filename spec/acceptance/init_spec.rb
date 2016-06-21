require 'spec_helper_acceptance'

describe 'cloudwatchlogs' do

  it_should_behave_like 'cloudwatchlogs::installed', "
      path            => '/var/log/messages',
      streamname      => 'thisIsABeakerTestHost'
  "

  it_should_behave_like 'cloudwatchlogs::running'

end
