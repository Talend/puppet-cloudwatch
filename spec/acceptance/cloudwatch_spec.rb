require 'spec_helper'

describe 'cloudwatch' do
  describe file('/opt/talend/cloudwatch/metrics.d/DiskPercentage') do
    it { should be_file }
    it { should be_mode 744 }
    its(:content) { should match /Disk_Metric/ }
  end

  describe file('/usr/local/bin/send_metrics') do
    it { should be_file }
    it { should be_mode 744 }
    its(:content) { should match /METRICS_PATH/ }
  end

  describe cron do
    it { should have_entry '*/1 * * * * /usr/local/bin/send_metrics' }
  end
end
