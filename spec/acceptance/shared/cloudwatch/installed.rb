require 'spec_helper_acceptance'

shared_examples 'cloudwatch::installed' do |parameters|

  it 'installs without errors' do
    pp = <<-EOS

    cloudwatch::metric{'default':
      #{parameters.to_s}
    }

    EOS

    apply_manifest(pp, :catch_failures => true)
    apply_manifest(pp, :catch_failures => true)
  end
end
