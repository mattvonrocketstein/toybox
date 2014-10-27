class neo::download {

  # Resource defaults
  Exec { path => '/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin' }

  require neo::params

  $downloadurl = "${neo::params::baseurl}/${neo::params::binpackage}"

  exec {
    'download-package':
      command => "curl ${neo::download::downloadurl} > ${neo::params::tmpdir}/${neo::params::binpackage}",
      unless  => "test -f ${neo::params::tmpdir}/${neo::params::binpackage}",
      timeout => 0
  }

}
