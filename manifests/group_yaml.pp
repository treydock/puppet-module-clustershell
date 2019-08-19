# @param ensure
# @param data
# @param source
# @param content
define clustershell::group_yaml (
  Enum['present','absent','file'] $ensure = 'present',
  Hash $data = {},
  Optional[String] $source = undef,
  Optional[String] $content = undef,
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
