require 'spec_helper'

describe 'cloudwatch' do

  let(:facts) {{ :osfamily => 'RedHat'}}

  context 'with default values for all parameters' do

    it {should compile}

    it { should contain_class('cloudwatch') }
    it { should contain_class('cloudwatch::install') }
    it { should contain_class('cloudwatch::config') }
    it { should contain_class('cloudwatch::params') }
    it { should contain_class('awscli') }

    it {should contain_file('/opt/cloudwatch-agent/metrics.d').with({
            'mode'   => '0744',
            'ensure' => 'directory',
            'owner'  => 'cloudwatch-agent',
        })
    }

    it {should contain_file('/opt/cloudwatch-agent/venv').with({
            'mode'   => '0744',
            'ensure' => 'directory',
            'owner'  => 'cloudwatch-agent',
        })
    }

    it {should contain_file('/var/log/cloudwatch-agent').with({
            'mode'   => '0744',
            'ensure' => 'directory',
            'owner'  => 'cloudwatch-agent',
        })
    }

    it {should contain_file('/opt/cloudwatch-agent/cloudwatch-agent.py').with({
            'mode'   => '0744',
            'ensure' => 'file',
            'owner'  => 'cloudwatch-agent',
        })

    it {should contain_file('/opt/cloudwatch-agent/configuration.yaml').with({
            'mode'   => '0744',
            'ensure' => 'file',
            'owner'  => 'cloudwatch-agent',
        })
    }

    it { should contain_cron('cloudwatch_metrics').with({
            'command' => '/opt/cloudwatch-agent/venv/bin/python /opt/cloudwatch-agent/cloudwatch-agent.py >/dev/null 2>&1',
            'user'    => 'cloudwatch-agent',
            'minute'  => '*/1',
        })
    }

  end
end
