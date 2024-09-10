# @summary Manage clustershell
#
# @example
#   include ::clustershell
#
# @param fanout
#   Value for clush.conf fanout
# @param connect_timeout
#   Value for clush.conf connect_timeout
# @param command_timeout
#   Value for clush.conf command_timeout
# @param color
#   Value for clush.conf color
# @param fd_max
#   Value for clush.conf fd_max
# @param history_size
#   Value for clush.conf history_size
# @param maxrc
#   Value for clush.conf maxrc
# @param node_count
#   Value for clush.conf node_count
# @param verbosity
#   Value for clush.conf verbosity
# @param confdir
#   Value for clush.conf confdir
# @param ssh_user
#   SSH user
# @param ssh_path
#   Path to SSH command
# @param ssh_options
#   SSH options
# @param ensure
#   Module ensure property
# @param package_name
#   clustershell package name
# @param package_ensure
#   The package ensure property, defaults based on `ensure` property
# @param manage_epel
#   Boolean that sets of EPEL module should be managed for Red Hat based systems
# @param install_python
#   Boolean that sets if python module should be installed
# @param python_package_name
#   Package name of python module, only applies to Red Hat based systems
# @param conf_dir
#   Path to clustershell configuration directory
# @param conf
#   Path to clush.conf
# @param conf_template
#   clush.conf template
# @param defaults_conf
#   Path to defaults.conf
# @param defaults_conf_template
#   defaults.conf template
# @param groups_config
#   path to local.cfg groups config file
# @param groups_concat_dir
#   groups concat directory
# @param groups_conf
#   path to groups.conf
# @param groups_conf_template
#   groups.conf template
# @param groups_auto_dir
#   path to groups auto directory
# @param groups_conf_dir
#   path to groups.conf.d
# @param include_slurm_groups
#   Boolean that sets if should include slurm groups
# @param default_group_source
#   The default group source
# @param default_distant_workername
#   The default remote command to use, usually `ssh` or `rsh`
# @param groupmembers
#   Hash of resources to pass to clustershell::groupmember
# @param group_yaml
#   Hash of resources to pass to clustershell::group_yaml
# @param include_genders_groups
#   Include genders group source
# @param manage_genders
#   Manage genders class when including genders group source
class clustershell (
  Integer $fanout = 64,
  Integer $connect_timeout = 15,
  Integer $command_timeout = 0,
  String $color = 'auto',
  Integer $fd_max = 8192,
  Integer $history_size = 100,
  String $maxrc = 'no',
  String $node_count = 'yes',
  String $verbosity = '1',
  String $confdir = '/etc/clustershell/clush.conf.d $CFGDIR/clush.conf.d',
  Optional[String] $ssh_user = undef,
  String $ssh_path = 'ssh',
  String $ssh_options = '-oStrictHostKeyChecking=no',
  Enum['present','absent'] $ensure = 'present',
  String $package_name = 'clustershell',
  Optional[String] $package_ensure = undef,
  Boolean $manage_epel = true,
  Boolean $install_python = false,
  String[1] $python_package_name = 'python3-clustershell',
  Stdlib::Absolutepath $conf_dir = '/etc/clustershell',
  Stdlib::Absolutepath $conf = '/etc/clustershell/clush.conf',
  Stdlib::Absolutepath $clush_conf_dir = '/etc/clustershell/clush.conf.d',
  String[1] $conf_template  = 'clustershell/clush.conf.erb',
  Stdlib::Absolutepath $defaults_conf = '/etc/clustershell/defaults.conf',
  String[1] $defaults_conf_template = 'clustershell/defaults.conf.erb',
  Stdlib::Absolutepath $groups_config = '/etc/clustershell/groups.d/local.cfg',
  Stdlib::Absolutepath $groups_concat_dir = '/etc/clustershell/tmp',
  Stdlib::Absolutepath $groups_conf = '/etc/clustershell/groups.conf',
  String[1] $groups_conf_template = 'clustershell/groups.conf.erb',
  Stdlib::Absolutepath $groups_auto_dir = '/etc/clustershell/groups.d',
  Stdlib::Absolutepath $groups_conf_dir = '/etc/clustershell/groups.conf.d',
  Boolean $include_slurm_groups = false,
  String $default_group_source = 'local',
  String $default_distant_workername = 'ssh',
  Hash $groupmembers = {},
  Hash $group_yaml = {},
  Boolean $include_genders_groups = false,
  Boolean $manage_genders = true,
) {
  if $ensure == 'absent' {
    $_package_ensure = pick($package_ensure, 'absent')
  } else {
    $_package_ensure = pick($package_ensure, 'present')
  }

  if dig($facts, 'os', 'family') == 'RedHat' {
    if $manage_epel {
      include epel
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

  file { '/etc/clustershell/clush.conf.d':
    ensure => 'directory',
    path   => $clush_conf_dir,
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
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
      all     => 'sinfo -a -h -o "%N"',
      list    => 'sinfo -a -h -o "%P" | sed \'s|*||g\'',
      reverse => 'sinfo -a -h -N -o "%P" -n $NODE',
    }
  }

  if $include_genders_groups {
    if $manage_genders {
      include genders
      Class['genders'] -> Clustershell::Group_source['genders']
    }
    clustershell::group_source { 'genders':
      ensure => $ensure,
      map    => 'nodeattr -n $GROUP',
      all    => 'nodeattr -n -A',
      list   => 'nodeattr -l',
    }
  }
}
