# puppet/modules/site/manifests/vcs_work.pp
#
class site::vcs_work{
  git::repo{'pg':
    path   => '/tmp/pg',
    branch => 'master',
    #source => 'git://example.org/example/repo.git'
    source => 'https://github.com/nesi/puppet-git.git'
  }-> exec {'chown -R vagrant:vagrant /tmp/pg':}
}
