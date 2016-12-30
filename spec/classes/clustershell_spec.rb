require 'spec_helper'

describe 'clustershell' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end

      it { should create_class('clustershell') }
      it { should contain_class('clustershell::params') }
      it { should contain_class('epel') }

      it do
        should contain_package('clustershell').with({
          :ensure   => 'present',
          :name     => 'clustershell',
          :require  => 'Yumrepo[epel]',
        })
      end

      it { should_not contain_package('vim-clustershell') }

      it do
        should contain_file('/etc/clustershell').with({
          :ensure   => 'directory',
          :path     => '/etc/clustershell',
          :owner    => 'root',
          :group    => 'root',
          :mode     => '0755',
          :require  => 'Package[clustershell]',
        })
      end

      it do
        should contain_file('/etc/clustershell/groups.conf.d').with({
          :ensure   => 'directory',
          :path     => '/etc/clustershell/groups.conf.d',
          :owner    => 'root',
          :group    => 'root',
          :mode     => '0755',
          :require  => 'File[/etc/clustershell]',
        })
      end

      it do
        should contain_file('/etc/clustershell/groups.d').with({
          :ensure   => 'directory',
          :path     => '/etc/clustershell/groups.d',
          :owner    => 'root',
          :group    => 'root',
          :mode     => '0755',
          :require  => 'File[/etc/clustershell]',
        })
      end

      it do
        should contain_file('/etc/clustershell/clush.conf').with({
          :ensure   => 'file',
          :owner    => 'root',
          :group    => 'root',
          :mode     => '0644',
          :require  => 'File[/etc/clustershell]',
        })
      end

      it do
        verify_exact_contents(catalogue, '/etc/clustershell/clush.conf', [
          '[Main]',
          'fanout: 64',
          'connect_timeout: 15',
          'command_timeout: 0',
          'color: auto',
          'fd_max: 8192',
          'history_size: 100',
          'node_count: yes',
          'verbosity: 1',
          'ssh_path: ssh',
          'ssh_options: -oStrictHostKeyChecking=no',
        ])
      end

      it do
        should contain_file('/etc/clustershell/groups.conf').with({
          :ensure   => 'file',
          :owner    => 'root',
          :group    => 'root',
          :mode     => '0644',
          :require  => 'File[/etc/clustershell]',
        })
      end

      it do
        verify_contents(catalogue, '/etc/clustershell/groups.conf', [
          '[Main]',
          'default: local',
          'confdir: /etc/clustershell/groups.conf.d $CFGDIR/groups.conf.d',
          'autodir: /etc/clustershell/groups.d $CFGDIR/groups.d'
        ])
      end

      it do
        should contain_datacat('clustershell-groups').with({
          :ensure   => 'present',
          :path     => '/etc/clustershell/groups.d/local.cfg',
          :owner    => 'root',
          :group    => 'root',
          :mode     => '0644',
          :template => 'clustershell/groups.erb',
          :require  => 'File[/etc/clustershell]',
        })
      end

      it { should_not contain_clustershell__group_source('slurm') }

      context 'when include_slurm_groups => true' do
        let(:params) {{ :include_slurm_groups => true }}

        it do
          should contain_clustershell__group_source('slurm').with({
            :ensure   => 'present',
            :map      => 'sinfo -h -o "%N" -p $GROUP',
            :all      => 'sinfo -h -o "%N"',
            :list     => 'sinfo -h -o "%P"',
            :reverse  => 'sinfo -h -N -o "%P" -n $NODE',
          })
        end
      end

      # Test validate_bool parameters
      [
        :ssh_enable,
        :install_vim_syntax,
        :include_slurm_groups,
      ].each do |param|
        context "with #{param} => 'foo'" do
          let(:params) {{ param.to_sym => 'foo' }}
          it "should raise error" do
            expect { should compile }.to raise_error(/is not a boolean/)
          end
        end
      end

      context "when ensure => 'foo'" do
        let(:params) {{ :ensure => 'foo' }}
        it "should raise error" do
          expect { should compile }.to raise_error(/ensure parameter must be present or absent/)
        end
      end
    end
  end
end
