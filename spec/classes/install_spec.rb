require 'spec_helper'

describe 'cloudwatch::install' do

  let(:facts) {{ :osfamily => 'RedHat'}}

  context 'with default values for all parameters' do

    it {should compile}
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
    }

    it {should contain_file('/opt/cloudwatch-agent/configuration.yaml').with({
            'mode'   => '0744',
            'ensure' => 'file',
            'owner'  => 'cloudwatch-agent',
        })
    }

  end
end
