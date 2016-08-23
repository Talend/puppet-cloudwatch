require 'spec_helper'

describe 'cloudwatch::metric' do

  let(:title) { 'default' }
  let(:facts) {{ :osfamily => 'RedHat'}}

  context 'metric with default values for all parameters' do

    let(:params) {{ :metric_executable => 'cloudwatch/metrics.d/example_script.sh'}}

    it { should compile }
    it { should contain_class('cloudwatch') }
    it { should contain_file('/opt/cloudwatch-agent/metrics.d/default').with_mode('0744') }

  end

  context 'metric without values for all parameters' do
    it { should compile.and_raise_error(/ERROR: param metric_executable is unset/) }
  end

  context 'metric with enabled alarm' do
    let(:params) {{ :metric_executable => 'cloudwatch/metrics.d/example_script.sh',
                    :alarm_enable      => true

    }}

    it { should compile }
    it { should contain_class('cloudwatch') }
    it { should contain_cloudwatch_alarm('default') }
    it { should contain_file('/opt/cloudwatch-agent/metrics.d/default').with_mode('0744') }

  end
end
