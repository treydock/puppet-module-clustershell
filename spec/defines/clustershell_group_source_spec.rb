require 'spec_helper'

describe 'clustershell::group_source' do
  let(:facts) {{ :osfamily => "RedHat" }}

  let(:title) { 'slurm' }

  let(:params) do
    {
      :map      => 'sinfo -h -o "%N" -p $GROUP',
      :all      => 'sinfo -h -o "%N"',
      :list     => 'sinfo -h -o "%P"',
      :reverse  => 'sinfo -h -N -o "%P" -n $NODE',
    }
  end

  it { should create_clustershell__group_source('slurm') }
  it { should contain_class('clustershell') }

  it do
    should contain_file('clustershell::group_source slurm').with({
      :ensure   => 'present',
      :path     => '/etc/clustershell/groups.conf.d/slurm.conf',
      :owner    => 'root',
      :group    => 'root',
      :mode     => '0644',
      :require  => 'File[/etc/clustershell/groups.conf.d]',
    })
  end

  it do
    verify_exact_contents(catalogue, 'clustershell::group_source slurm', [
      '[slurm]',
      'map: sinfo -h -o "%N" -p $GROUP',
      'all: sinfo -h -o "%N"',
      'list: sinfo -h -o "%P"',
      'reverse: sinfo -h -N -o "%P" -n $NODE',
    ])
  end
end
