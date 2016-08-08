# See README.md for details
define clustershell::group_yaml (
  $ensure   = 'present',
  $source   = undef,
  $content  = undef,
) {

  include ::clustershell

  $path = "${::clustershell::groups_auto_dir}/${name}.yaml"

  file { "clustershell::group_yaml ${name}":
    ensure  => $ensure,
    path    => $path,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => $content,
    source  => $source,
  }

}
