require 'spec_helper'

describe 'cloudwatch::config' do

  let(:facts) {{ :osfamily => 'RedHat'}}

  context 'with default values for all parameters' do

    it {should compile}

    it { should contain_cron('cloudwatch_metrics').with({
            'command' => '/opt/cloudwatch-agent/venv/bin/python /opt/cloudwatch-agent/cloudwatch-agent.py >/dev/null 2>&1',
            'user'    => 'cloudwatch-agent',
            'minute'  => '*/1',
        })
    }

  end
end
