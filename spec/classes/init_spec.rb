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

  end
end
