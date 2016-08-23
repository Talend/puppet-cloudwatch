require 'spec_helper'

describe 'cloudwatch' do

  let(:facts) {{ :osfamily => 'RedHat'}}

  context 'with default values for all parameters' do

    it {should compile}

    it {
        should contain_class('cloudwatch')
        should contain_class('cloudwatch::params')
        should contain_class('cloudwatch::install')
        should contain_class('cloudwatch::config')
        should contain_class('cloudwatch::params')
    }

  end
end
