require 'spec_helper'

describe 'cloudwatch' do
  
  describe user('cloudwatch-agent') do
    it { should exist }
  end

  describe file('/opt/cloudwatch-agent/cloudwatch-agent.py') do
    it { should be_file }
    it { should be_mode 744 }
    it { should be_owned_by 'cloudwatch-agent' }
  end

  describe file('/opt/cloudwatch-agent/configuration.yaml') do
    it { should be_file }
    it { should be_mode 744 }
    it { should be_owned_by 'cloudwatch-agent' }
  end

  describe cron do
    it do
      should have_entry('*/1 * * * * flock -n 200 /opt/cloudwatch-agent/venv/bin/python' \
        '/opt/cloudwatch-agent/cloudwatch-agent.py >/dev/null 2>&1').with_user('cloudwatch-agent')
    end
  end
end
