require 'spec_helper_acceptance'

shared_examples 'cloudwatchlogs::installed' do |parameters|

  it 'installs without errors' do
    pp = <<-EOS

    cloudwatchlogs::log{'beaker_test':
      #{parameters.to_s}
    }

    EOS

    apply_manifest(pp, :catch_failures => true)
    apply_manifest(pp, :catch_failures => true)
  end
end
