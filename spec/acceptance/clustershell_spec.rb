# frozen_string_literal: true

require 'spec_helper_acceptance'

describe 'clustershell class:' do
  python = if fact('os.family') == 'RedHat' && fact('os.release.major').to_i == 8
             'python3'
           elsif fact('os.family') == 'Debian' && fact('os.release.major') == '20.04'
             'python3'
           else
             'python'
           end

  context 'with default parameters' do
    it 'runs successfully' do
      pp = <<-PP
      class { 'clustershell':
        install_python => true,
      }
      PP

      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
    end

    describe package('clustershell') do
      it { is_expected.to be_installed }
    end

    describe command("#{python} -c 'from ClusterShell.NodeSet import NodeSet'") do
      its(:exit_status) { is_expected.to eq 0 }
    end
  end
end
