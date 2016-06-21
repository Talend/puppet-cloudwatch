require 'spec_helper'
describe 'cloudwatch' do

  context 'with default values for all parameters' do
    it { should contain_class('cloudwatch') }
  end
end
