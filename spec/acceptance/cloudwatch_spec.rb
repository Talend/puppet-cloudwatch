require 'spec_helper'

describe 'cloudwatch' do
  
  describe user('cloudwatch-agent') do
    it { should exist }
  end

  describe file('/opt/cloudwatch-agent/') do
    it { should be_directory }
    it { should be_mode 755 }
    it { should be_owned_by 'cloudwatch-agent' }
  end

  describe file('/var/log/cloudwatch-agent/') do
    it { should be_directory }
    it { should be_mode 755 }
    it { should be_owned_by 'cloudwatch-agent' }
  end

  describe file('/opt/cloudwatch-agent/cw_agent.py') do
    it { should be_file }
    it { should be_mode 755 }
    it { should be_owned_by 'cloudwatch-agent' }
  end

  describe file('/opt/cloudwatch-agent/venv/bin/python') do
    it { should be_file }
    it { should be_executable.by('owner') }
    it { should be_owned_by 'cloudwatch-agent' }
  end

  describe file('/opt/cloudwatch-agent/logging.yaml') do
    it { should be_file }
    it { should be_mode 755 }
    it { should be_owned_by 'cloudwatch-agent' }
  end

  describe file('/opt/cloudwatch-agent/metrics.yaml') do
    it { should be_file }
    it { should be_mode 644 }
    it { should be_owned_by 'cloudwatch-agent' }
  end

  describe cron do
    it do
      should have_entry('*/1 * * * * flock -n /tmp/cloudwatch-agent.lock /opt/cloudwatch-agent/venv/bin/python '\
      '/opt/cloudwatch-agent/cw_agent.py --metrics /opt/cloudwatch-agent/metrics.yaml '\
      '>/dev/null 2>&1').with_user('cloudwatch-agent')
    end
  end
end
