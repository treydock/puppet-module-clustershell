# @param map
# @param ensure
# @param all
# @param list
# @param reverse
# @param section
define clustershell::group_source (
  String $map,
  Enum['present','absent','file'] $ensure = 'present',
  String $all = 'UNSET',
  String $list = 'UNSET',
  String $reverse = 'UNSET',
  String $section = $name,
) {

  include ::clustershell

  $path = "${::clustershell::groups_conf_dir}/${name}.conf"

  file { "clustershell::group_source ${name}":
    ensure  => $ensure,
    path    => $path,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('clustershell/group_source.conf.erb'),
    require => File['/etc/clustershell/groups.conf.d'],
  }

}
