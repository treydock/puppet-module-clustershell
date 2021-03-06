require 'spec_helper_acceptance'

describe 'clustershell class:' do
  context 'default parameters' do
    it 'runs successfully' do
      pp = <<-EOS
      class { 'clustershell': }
      EOS

      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
    end

    describe package('clustershell') do
      it { is_expected.to be_installed }
    end
  end
end
