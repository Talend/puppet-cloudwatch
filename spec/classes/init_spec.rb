require 'spec_helper'

describe 'cloudwatch' do

  let(:facts) {{ :osfamily => 'RedHat'}}

  context 'with default values for all parameters' do

    it {should compile}

    it { should contain_class('cloudwatch') }
    it { should contain_class('awscli') }

    it {should contain_file('/opt/talend/cloudwatch/metrics.d').with({
                                                                         'mode' => '0755',
                                                                         'ensure' => 'directory'
                                                                     })
    }

    it { should contain_cron('cloudwatch_metrics').with({
                                                            'command' => '/usr/local/bin/send_metrics',
                                                            'user'    => 'root',
                                                            'minute'  => '*/1',
                                                        }) }

  end
end
