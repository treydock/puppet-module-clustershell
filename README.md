# puppet-module-clustershell

[![Puppet Forge](http://img.shields.io/puppetforge/v/treydock/clustershell.svg)](https://forge.puppetlabs.com/treydock/clustershell)
[![Build Status](https://travis-ci.org/treydock/puppet-module-clustershell.png)](https://travis-ci.org/treydock/puppet-module-clustershell)

#### Table of Contents

1. [Description](#description)
2. [Setup - The basics of getting started with clustershell](#setup)
    * [What clustershell affects](#what-clustershell-affects)
    * [Setup requirements](#setup-requirements)
3. [Usage - Configuration options and additional functionality](#usage)
4. [Reference - Module reference](#reference)


## Description

This module will manage [ClusterShell](https://clustershell.readthedocs.io/en/latest/)

## Setup

### What clustershell affects

This module will install the clustershell packages and manage the clustershell configs.

### Setup Requirements

For systems with `yum` package manager using Puppet >= 6.0 there is a dependency on [puppetlabs/yumrepo_core](https://forge.puppet.com/puppetlabs/yumrepo_core).

If genders support is enabled there is a soft dependency on [treydock/genders](https://forge.puppet.com/treydock/genders)

## Usage

Install clustershell and define groups in local.cfg:

```puppet
class { '::clustershell':
  groups => [
    'compute: node[00-99]',
    'login: login[01-02]',
  ],
}
```

Enable SLURM groups and make them the default:

```puppet
class { '::clustershell':
  default_group_source => 'slurm',
  include_slurm_groups => true,
}
```

Enable genders groups and make them the default:

```puppet
class { '::clustershell':
  default_group_source   => 'genders',
  include_genders_groups => true,
}
```

Define groups via YAML group files:

```puppet
class { '::clustershell':
  group_yaml => {
    'cluster' => {
      'data'  => {
        'local' => {
          'compute' => 'node[00-99]',
          'login'   => 'login[01-02]',
        }
      }
    }
  }
}
```

Defining group YAML files via defined type:

```puppet
::clustershell::group_yaml { 'cluster':
  data => {
    'local' => {
      'compute' => 'node[00-99]',
      'login'   => 'login[01-02]',
    }
  }
}
```

Can also supply custom templates to `clustershell::group_yaml`

```puppet
::clustershell::group_yaml { 'cluster':
  content => template('profile/clustershell/cluster.yaml.erb'),
}
```

Example of defining custom group source:

```puppet
::clustershell::group_source { 'batch':
  ensure  => 'present',
  section => 'job,moabrsv',
  map     => 'clustershell-batch-mapper.py $SOURCE map $GROUP',
  list    => 'clustershell-batch-mapper.py $SOURCE list',
}
```


## Reference

[http://treydock.github.io/puppet-module-clustershell/](http://treydock.github.io/puppet-module-clustershell/)
