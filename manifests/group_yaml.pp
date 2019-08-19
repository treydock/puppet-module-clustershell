# @summary Manage a group yaml file
#
# @example
#   clustershell::group_yaml { 'roles':
#     data => {
#       'roles' => {
#         'compute' => 'compute[01-04]',
#         'login'   => 'login[01-02]',
#       }
#     }
#   }
#
# @param ensure
#   File ensure property
# @param data
#   The data to use in defining the YAML groups
# @param source
#   Source that can be used to define the YAML file
# @param content
#   Content that can override this module's template for this YAML file
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
