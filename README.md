# Puppet module for managing ClusterShell

## Overview

Installs and configures ClusterShell

## Usage

### clustershell

Install the vim syntax package and configure groups:

    class { 'clustershell':
      install_vim_syntax => true,
      groups             => [
        'hpc: node[00-99]',
        'nfs: nfs1 nfs2 nfs3',
      ],
    }

### clustershell::group_source

Example which is used if clustershell `include_slurm_groups` is true.

    clustershell::group_source { 'slurm':
      ensure  => $ensure,
      map     => 'sinfo -h -o "%N" -p $GROUP',
      all     => 'sinfo -h -o "%N"',
      list    => 'sinfo -h -o "%P"',
      reverse => 'sinfo -h -N -o "%P" -n $NODE',
    }


## Reference

### Classes

#### Public classes

* `clustershell`: Installs and configures clustershell

#### Private classes

* `clustershell::params`: Defines default parameter values

#### clustershell

#####`groups`

An array of groups used by clustershell programs.

#####`fanout`

The clush.conf `fanout` value.  Default is 64.

#####`connect_timeout`

The clush.conf `connect_timeout` value.  Default is 15

#####`command_timeout`

The clush.conf `command_timeout` value.  Default is 0

#####`color`

The clush.conf `color` value.  Default is 'auto'

#####`fd_max`

The clush.conf `fd_max` value.  Default is 16384

#####`history_size`

The clush.conf `history_size` value.  Default is 100

#####`node_count`

The clush.conf `node_count` value.  Default is 'yes'

#####`verbosity`

The clush.conf `verbosity` value.  Default is '1'

#####`ssh_enable`

Controls whether or not clush uses SSH settings from the config.  Default is false

#####`ssh_user`

The user to use with SSH.  Default is 'root'

#####`ssh_path`

The path to the SSH client.  Default is '/usr/bin/ssh'

#####`ssh_options`

Command line options to pass to the SSH client.  Default is '-oStrictHostKeyChecking=no'

#####`ensure`

Ensure if present or absent.  Default is 'present'

#####`package_require`

Resource required to install the clustershell package.  Default is OS dependent.

#####`package_name`

clustershell package name.  Default is OS dependent.

#####`install_vim_syntax`

Whether or not to install the VIM package for syntax highlighting.  Default is false.

#####`vim_package_name`

Name of the package for VIM syntax highlighting.  Default is OS dependent.

#####`clush_conf_dir`

Directory for clustershell configs.  Default is OS dependent.

#####`clush_conf`

Path to clush.conf.  Default is OS dependent.

#####`clush_conf_template`

Path to clush.conf Puppet template.  Default is 'clustershell/clush.conf.erb'.

#####`groups_config`

Path to groups config file.  Default is OS dependent.

#####`groups_template`

Path to groups Puppet template.  Default is 'clustershell/groups.erb'.

#####`groups_conf`

Path to groups.conf.  Default is OS dependent.

#####`groups_conf_template`

Path to groups.conf Puppet template.  Default is 'clustershell/groups.conf.erb'.

#####`groups_dir`

Path to groups.conf.d.  Default is OS dependent.

#####`include_slurm_groups`

Determines if the slurm groups should be included.  Default is false.
