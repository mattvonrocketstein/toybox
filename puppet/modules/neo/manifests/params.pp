class neo::params {

  case $operatingsystem {
    /(Ubuntu|Debian)/: {
      $jreinstaller = 'default-jre'
    }
    /(RedHat|CentOS|Fedora)/: {
      $jreinstaller = 'java-1.6.0-openjdk'
    }
  }

  $tmpdir = '/vagrant'
  $baseurl = 'http://dist.neo4j.org'
  #$baseurl = 'file:////mnt/localrepo'
  $neoversion     = 'neo4j-community-1.7.2'
  $binpackage = "${neoversion}-unix.tar.gz"
  $installationdir = '/opt/neo4j'
  $neouser = 'neo4j'
  $ulimitn = '40000'

}
