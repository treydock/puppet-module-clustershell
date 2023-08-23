# @summary Define group sources
#
# @example
#   clustershell::group_source { 'slurm':
#      ensure  => 'present',
#      map     => 'sinfo -h -o "%N" -p $GROUP',
#      all     => 'sinfo -h -o "%N"',
#      list    => 'sinfo -h -o "%P"',
#      reverse => 'sinfo -h -N -o "%P" -n $NODE',
#    }
#
# @param map
#   map command
# @param ensure
#   Ensure property
# @param all
#   all command
# @param list
#   list command
# @param reverse
#   reverse command
# @param section
#   Name of section for group source
define clustershell::group_source (
  String $map,
  Enum['present','absent','file'] $ensure = 'present',
  String $all = 'UNSET',
  String $list = 'UNSET',
  String $reverse = 'UNSET',
  String $section = $name,
) {
  include clustershell

  $path = "${clustershell::groups_conf_dir}/${name}.conf"

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
