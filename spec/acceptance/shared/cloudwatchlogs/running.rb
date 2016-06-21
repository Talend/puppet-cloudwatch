require 'spec_helper_acceptance'

shared_examples 'cloudwatchlogs::running' do

  describe file('/var/log/awslogs.log'), :retry => 3, :retry_wait => 10 do
    its(:content) { should match /Log group: beaker_test, log stream: thisIsABeakerTestHost/ }
  end

  describe file('/var/log/awslogs.log'), :retry => 3, :retry_wait => 10 do
    its(:content) { should_not match /ERROR/ }
  end

end


