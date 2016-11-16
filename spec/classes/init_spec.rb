require 'spec_helper'

describe 'cloudwatch' do
  let(:facts) {{ :osfamily => 'RedHat'}}
  context 'with default values for all parameters' do
    it {should compile}

    it do
      should contain_class('cloudwatch')
      should contain_class('cloudwatch::params')
      should contain_class('cloudwatch::install')
      should contain_class('cloudwatch::config')
      should contain_class('cloudwatch::params')
    end

    #######################
    # Test : installation #
    #######################

    it do
      should contain_class('python')
    end

    it do
      should contain_user('cloudwatch-agent').with({
        :ensure   => 'present',
        :comment  => 'User for CloudWatch Agent',
      })
    end

    it do
      should contain_file('/opt/cloudwatch-agent').with({
        :mode    => '0755',
        :ensure  => 'directory',
        :owner   => 'cloudwatch-agent',
        :source  => 'puppet:///modules/cloudwatch/cloudwatch_agent/',
        :recurse => 'remote',
      })
    end

    it do
      should contain_file('/opt/cloudwatch-agent/requirements.txt').with({
        :ensure => 'present',
        :source => 'puppet:///modules/cloudwatch/cloudwatch_agent/requirements.txt',
      })
    end

    it do
      is_expected.to contain_python__virtualenv('/opt/cloudwatch-agent/venv').with({
        :ensure       => 'present',
        :version      => 'system',
        :requirements => '/opt/cloudwatch-agent/requirements.txt',
        :venv_dir     => '/opt/cloudwatch-agent/venv',
        :owner        => 'cloudwatch-agent',
        :group        => 'cloudwatch-agent',
      })
    end

    it do
      should contain_file('/var/log/cloudwatch-agent').with({
        :ensure => 'directory',
        :mode    => '0755',
        :owner   => 'cloudwatch-agent',
      })
    end

    ########################
    # Test : configuration #
    ########################

    it do
      is_expected.to contain_file_line('Set namespace').with({
        :ensure => 'present',
      })
    end

    it do
      should contain_file('/opt/cloudwatch-agent/metrics.yaml').with({
        :ensure => 'present',
        :mode    => '0644',
        :owner   => 'cloudwatch-agent',
      })
    end

    it do
      should contain_cron('CloudWatch Agent').with({
        :command => 'flock -n /tmp/cloudwatch-agent.lock /opt/cloudwatch-agent/venv/bin/python /opt/cloudwatch-agent/cw_agent.py '\
                    '--metrics /opt/cloudwatch-agent/metrics.yaml >/dev/null 2>&1',
        :user    => 'cloudwatch-agent',
        :minute  => '*/1',
      })
    end
  end
end