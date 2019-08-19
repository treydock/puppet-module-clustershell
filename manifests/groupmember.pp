# @param group
# @param member
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
