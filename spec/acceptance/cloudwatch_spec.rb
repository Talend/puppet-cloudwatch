require 'spec_helper'

  describe file('/opt/cloudwatch-agent/cloudwatch-agent.py') do
    it { should be_file }
    it { should be_mode 744 }
    if { should be_owned_by 'cloudwatch-agent' }
  end

  describe cron do
    it { should have_entry('*/1 * * * * /opt/cloudwatch-agent/venv/bin/python /opt/cloudwatch-agent/cloudwatch-agent.py >/dev/null 2>&1').with_user('cloudwatch-agent') }
  end
end
