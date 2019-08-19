# @summary Manage local.cfg group members
#
# @example
#   clustershell::groupmember { 'compute':
#     group   => 'compute',
#     member  => 'compute[01-02]',
#   }
#
# @param group
#   Name of the group
# @param member
#   Members
define clustershell::groupmember (
  String $group,
  Variant[Array, String] $member = $title,
) {

  if $member =~ String {
    $members = [$member]
  } else {
    $members = $member
  }
  $_members = join($members, ',')

  concat::fragment { "clustershell-groups.member ${title}":
    target  => '/etc/clustershell/groups.d/local.cfg',
    content => "${group}: ${_members}\n",
    order   => '50',
  }

}
