# == Class: clustershell
#
# Handles installing the clustershell packages.
#
# ==== Parameters:
#
# [*fanout*]
#   ...
#   Default: 64
#
# [*connect_timeout*]
#   ...
#   Default: 15
#
# [*command_timeout*]
#   ...
#   Default: 0
#
# [*color*]
#   ...
#   Default: auto
#
# [*fd_max*]
#   ...
#   Default: 16384
#
# [*history_size*]
#   ...
#   Default: 100
#
# [*node_count*]
#   ...
#   Default: yes
#
# [*verbosity*]
#   ...
#   Default: 1
#
# [*ssh_enable*]
#   Controls whether or not clush uses SSH settings from the config.
#   Default: false
#
# [*ssh_user*]
#   The user to use with SSH.
#   Default: root
#
# [*ssh_path*]
#   The path to the SSH client.
#   Default: /usr/bin/ssh
#
# [*ssh_options*]
#   Command line options to pass to the SSH client.
#   Default: -oStrictHostKeyChecking=no
#
# [*ensure*]
#   Ensure if present or absent.
#   Default: present
#
# [*package_name*]
#   Name of the package.
#   Default: clustershell
#
# [*install_vim_syntax*]
#   Whether or not to install the VIM package for syntax highlighting.
#   Default: false
#
# [*vim_package_name*]
#   Name of the package for VIM syntax highlighting.
#   Default: vim-clustershell
#
# === Actions:
#
# Installs the clustershell package and configuration.
# Installs the vim-clustershell package.
#
# === Requires:
#
# Nothing.
#
# === Sample Usage:
#
#  # Install the vim syntax package and configure groups:
#  class { 'clustershell':
#    install_vim_syntax => true,
#    groups             => [
#      'hpc: node[00-99]',
#      'nfs: nfs1 nfs2 nfs3',
#    ],
#  }
#
# === Authors:
#
# Geoff Johnson <geoff.jay@gmail.com>
#
# === Copyright:
#
# Copyright (C) 2014 Geoff Johnson, unless otherwise noted.
#

class clustershell (
  $fanout               = $clustershell::params::fanout,
  $connect_timeout      = $clustershell::params::connect_timeout,
  $command_timeout      = $clustershell::params::command_timeout,
  $color                = $clustershell::params::color,
  $fd_max               = $clustershell::params::fd_max,
  $history_size         = $clustershell::params::history_size,
  $node_count           = $clustershell::params::node_count,
  $verbosity            = $clustershell::params::verbosity,
  $ssh_enable           = $clustershell::params::ssh_enable,
  $ssh_user             = $clustershell::params::ssh_user,
  $ssh_path             = $clustershell::params::ssh_path,
  $ssh_options          = $clustershell::params::ssh_options,
  $ensure               = $clustershell::params::ensure,
  $package_require      = $clustershell::params::package_require,
  $package_name         = $clustershell::params::package_name,
  $install_vim_syntax   = $clustershell::params::install_vim_syntax,
  $vim_package_name     = $clustershell::params::vim_package_name,
  $clush_conf_dir       = $clustershell::params::clush_conf_dir,
  $clush_conf           = $clustershell::params::clush_conf,
  $clush_conf_template  = $clustershell::params::clush_conf_template,
  $groups_config        = $clustershell::params::groups_config,
  $groups_concat_dir    = $clustershell::params::groups_concat_dir,
  $groups_conf          = $clustershell::params::groups_conf,
  $groups_conf_template = $clustershell::params::groups_conf_template,
  $groups_auto_dir      = $clustershell::params::groups_auto_dir,
  $groups_conf_dir      = $clustershell::params::groups_conf_dir,
  $include_slurm_groups = false,
  $default_group_source = 'local',
  $groupmembers         = $clustershell::params::groupmembers,
  $group_yaml           = {},
) inherits clustershell::params {

  validate_bool($ssh_enable)
  validate_bool($install_vim_syntax)
  validate_bool($include_slurm_groups)
  validate_hash($groupmembers)

  case $ensure {
    /(present)/: {
      $package_ensure = 'present'
    }
    /(absent)/: {
      $package_ensure = 'absent'
    }
    default: {
      fail('ensure parameter must be present or absent')
    }
  }

  case $::osfamily {
    'RedHat': {
      include ::epel
    }
    default: {
      # Do nothing
    }
  }

  package { 'clustershell':
    ensure  => $package_ensure,
    name    => $package_name,
    require => $package_require,
  }

  # Might need to convert to class
  if $install_vim_syntax {
    package { 'vim-clustershell':
      ensure  => $package_ensure,
      name    => $vim_package_name,
      require => $package_require,
    }
  }

  file { '/etc/clustershell':
    ensure  => 'directory',
    path    => $clush_conf_dir,
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    require => Package['clustershell'],
  }

  file { '/etc/clustershell/groups.conf.d':
    ensure  => 'directory',
    path    => $groups_conf_dir,
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    require => File['/etc/clustershell'],
  }

  file { '/etc/clustershell/groups.d':
    ensure  => 'directory',
    path    => $groups_auto_dir,
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    purge   => true,
    recurse => true,
    require => File['/etc/clustershell'],
  }

  file { $clush_conf:
    ensure  => 'file',
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    require => File['/etc/clustershell'],
    content => template($clush_conf_template),
  }

  file { $groups_conf:
    ensure  => 'file',
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    require => File['/etc/clustershell'],
    content => template($groups_conf_template),
  }

  datacat { 'clustershell-groups':
    ensure   => 'present',
    path     => $groups_config,
    owner    => 'root',
    group    => 'root',
    mode     => '0644',
    template => 'clustershell/groups.erb',
    require  => File['/etc/clustershell'],
  }

  create_resources('clustershell::groupmember', $groupmembers)
  create_resources('clustershell::group_yaml', $group_yaml)

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
