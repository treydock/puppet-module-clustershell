require 'spec_helper'

describe 'clustershell' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end

      it { is_expected.to create_class('clustershell') }
      if facts[:os]['family'] == 'RedHat'
        package_require = 'Yumrepo[epel]'
        it { is_expected.to contain_class('epel') }
      else
        package_require = nil
      end

      it do
        is_expected.to contain_package('clustershell').with(ensure: 'present',
                                                            name: 'clustershell',
                                                            require: package_require)
      end

      it { is_expected.not_to contain_package('python-clustershell') }

      it do
        is_expected.to contain_file('/etc/clustershell').with(ensure: 'directory',
                                                              path: '/etc/clustershell',
                                                              owner: 'root',
                                                              group: 'root',
                                                              mode: '0755',
                                                              require: 'Package[clustershell]')
      end

      it do
        is_expected.to contain_file('/etc/clustershell/groups.conf.d').with(ensure: 'directory',
                                                                            path: '/etc/clustershell/groups.conf.d',
                                                                            owner: 'root',
                                                                            group: 'root',
                                                                            mode: '0755')
      end

      it do
        is_expected.to contain_file('/etc/clustershell/groups.d').with(ensure: 'directory',
                                                                       path: '/etc/clustershell/groups.d',
                                                                       owner: 'root',
                                                                       group: 'root',
                                                                       mode: '0755')
      end

      it do
        is_expected.to contain_file('/etc/clustershell/clush.conf').with(ensure: 'file',
                                                                         owner: 'root',
                                                                         group: 'root',
                                                                         mode: '0644')
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
        is_expected.to contain_file('/etc/clustershell/groups.conf').with(ensure: 'file',
                                                                          owner: 'root',
                                                                          group: 'root',
                                                                          mode: '0644')
      end

      it do
        verify_contents(catalogue, '/etc/clustershell/groups.conf', [
                          '[Main]',
                          'default: local',
                          'confdir: /etc/clustershell/groups.conf.d $CFGDIR/groups.conf.d',
                          'autodir: /etc/clustershell/groups.d $CFGDIR/groups.d',
                        ])
      end

      it do
        is_expected.to contain_concat('/etc/clustershell/groups.d/local.cfg').with(ensure: 'present',
                                                                                   path: '/etc/clustershell/groups.d/local.cfg',
                                                                                   owner: 'root',
                                                                                   group: 'root',
                                                                                   mode: '0644',
                                                                                   require: 'File[/etc/clustershell/groups.d]')
      end

      it { is_expected.not_to contain_clustershell__group_source('slurm') }

      context 'when include_slurm_groups => true' do
        let(:params) { { include_slurm_groups: true } }

        it do
          is_expected.to contain_clustershell__group_source('slurm').with(ensure: 'present',
                                                                          map: 'sinfo -h -o "%N" -p $GROUP',
                                                                          all: 'sinfo -h -o "%N"',
                                                                          list: 'sinfo -h -o "%P"',
                                                                          reverse: 'sinfo -h -N -o "%P" -n $NODE')
        end
      end

      context 'when group_yaml defined' do
        let(:params) do
          {
            group_yaml: {
              'nodes' => {
                'data' => {
                  'roles' => {
                    'compute' => 'compute[01-04]',
                  },
                },
              },
            },
          }
        end

        it { is_expected.to contain_clustershell__group_yaml('nodes') }
      end
    end
  end
end
