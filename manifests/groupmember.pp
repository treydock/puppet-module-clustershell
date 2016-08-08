# Juste a simple concat files to manage groups
define clustershell::groupmember (
  $group,
  $member = $title,
) {

  $data = {
    "${group}" => any2array($member),
  }

  datacat_fragment { "clustershell::groupmember ${title}":
    target => 'clustershell-groups',
    data   => $data,
  }

}
