# See README.md for details
define clustershell::group_yaml (
  $ensure   = 'present',
  $data     = {},
  $source   = undef,
  $content  = undef,
) {

  include ::clustershell

  $path = "${::clustershell::groups_auto_dir}/${name}.yaml"

  if ! $source and ! $content {
    $_content = template('clustershell/group_yaml.erb')
  } else {
    $_content = $content
  }

  file { "clustershell::group_yaml ${name}":
    ensure  => $ensure,
    path    => $path,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => $_content,
    source  => $source,
  }

}
