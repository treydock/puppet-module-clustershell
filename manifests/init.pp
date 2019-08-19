# @summary Manage clustershell
#
#
#
# @param fanout
# @param connect_timeout
# @param command_timeout
# @param color
# @param fd_max
# @param history_size
# @param node_count
# @param verbosity
# @param ssh_enable
# @param ssh_user
# @param ssh_path
# @param ssh_options
# @param ensure
# @param package_name
# @param package_ensure
# @param manage_epel
# @param install_python
# @param python_package_name
# @param conf_dir
# @param conf
# @param conf_template
# @param defaults_conf
# @param defaults_conf_template
# @param groups_config
# @param groups_concat_dir
# @param groups_conf
# @param groups_conf_template
# @param groups_auto_dir
# @param groups_conf_dir
# @param include_slurm_groups
# @param default_group_source
# @param default_distant_workername
# @param groupmembers
# @param group_yaml

class clustershell (
  Integer $fanout = 64,
  Integer $connect_timeout = 15,
  Integer $command_timeout = 0,
  String $color = 'auto',
  Integer $fd_max = 8192,
  Integer $history_size = 100,
  String $node_count = 'yes',
  String $verbosity = '1',
  Boolean $ssh_enable   = false,
  Optional[String] $ssh_user = undef,
  String $ssh_path = 'ssh',
  String $ssh_options = '-oStrictHostKeyChecking=no',
  Enum['present','absent'] $ensure = 'present',
  String $package_name = 'clustershell',
  Optional[String] $package_ensure = undef,
  Boolean $manage_epel = true,
  Boolean $install_python = false,
  Optional[String] $python_package_name = undef,
  Stdlib::Absolutepath $conf_dir = '/etc/clustershell',
  Stdlib::Absolutepath $conf = '/etc/clustershell/clush.conf',
  $conf_template  = 'clustershell/clush.conf.erb',
  Stdlib::Absolutepath $defaults_conf = '/etc/clustershell/defaults.conf',
  $defaults_conf_template = 'clustershell/defaults.conf.erb',
  Stdlib::Absolutepath $groups_config = '/etc/clustershell/groups.d/local.cfg',
  Stdlib::Absolutepath $groups_concat_dir = '/etc/clustershell/tmp',
  Stdlib::Absolutepath $groups_conf = '/etc/clustershell/groups.conf',
  $groups_conf_template = 'clustershell/groups.conf.erb',
  Stdlib::Absolutepath $groups_auto_dir = '/etc/clustershell/groups.d',
  Stdlib::Absolutepath $groups_conf_dir = '/etc/clustershell/groups.conf.d',
  Boolean $include_slurm_groups = false,
  String $default_group_source = 'local',
  String $default_distant_workername = 'ssh',
  Hash $groupmembers = {},
  Hash $group_yaml = {},
) {

  if $ensure == 'absent' {
    $_package_ensure = pick($package_ensure, 'absent')
  } else {
    $_package_ensure = pick($package_ensure, 'present')
  }

  if dig($facts, 'os', 'family') == 'RedHat' {
    if $manage_epel {
      include ::epel
      $package_require = Yumrepo['epel']
    } else {
      $package_require = undef
    }
  } else {
    $package_require = undef
  }

  package { 'clustershell':
    ensure  => $_package_ensure,
    name    => $package_name,
    require => $package_require,
  }

  # Might need to convert to class
  if $install_python and $python_package_name {
    package { 'python-clustershell':
      ensure  => $_package_ensure,
      name    => $python_package_name,
      require => Package['clustershell'],
    }
  }

  file { '/etc/clustershell':
    ensure  => 'directory',
    path    => $conf_dir,
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    require => Package['clustershell'],
  }

  file { '/etc/clustershell/groups.conf.d':
    ensure => 'directory',
    path   => $groups_conf_dir,
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
  }

  file { '/etc/clustershell/groups.d':
    ensure  => 'directory',
    path    => $groups_auto_dir,
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    purge   => true,
    recurse => true,
  }

  file { '/etc/clustershell/clush.conf':
    ensure  => 'file',
    path    => $conf,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    require => File['/etc/clustershell'],
    content => template($conf_template),
  }

  file { '/etc/clustershell/defaults.conf':
    ensure  => 'file',
    path    => $defaults_conf,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template($defaults_conf_template),
  }

  file { '/etc/clustershell/groups.conf':
    ensure  => 'file',
    path    => $groups_conf,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template($groups_conf_template),
  }

  concat { '/etc/clustershell/groups.d/local.cfg':
    ensure  => 'present',
    path    => $groups_config,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    require => File['/etc/clustershell/groups.d'],
  }
  concat::fragment { 'clustershell-groups.header':
    target  => '/etc/clustershell/groups.d/local.cfg',
    content => "### File managed by Puppet\n",
    order   => '01',
  }

  $groupmembers.each |$name, $data| {
    clustershell::groupmember { $name: * => $data }
  }
  $group_yaml.each |$name, $data| {
    clustershell::group_yaml { $name: * => $data }
  }

  if $include_slurm_groups {
    clustershell::group_source { 'slurm':
      ensure  => $ensure,
      map     => 'sinfo -h -o "%N" -p $GROUP',
      all     => 'sinfo -h -o "%N"',
      list    => 'sinfo -h -o "%P"',
      reverse => 'sinfo -h -N -o "%P" -n $NODE',
    }
  }
}
