require 'spec_helper'

describe 'cloudwatch::metric' do

  let(:title) { 'default' }
  let(:facts) {{ :osfamily => 'RedHat'}}

  context 'metric with default values for all parameters' do

    let(:params) {{ :metric_executable => 'cloudwatch/talend/example_sript.sh.erb'}}

    it {should compile}
    it { should contain_class('cloudwatch') }
    it {should contain_file('/opt/talend/cloudwatch/metrics.d/default_metric').with_mode('0744') }
  end

  context 'metric without values for all parameters' do

    it { should compile.and_raise_error(/ERROR: param metric_executable is unset/) }

  end
end
