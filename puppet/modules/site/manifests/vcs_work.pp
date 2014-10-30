# puppet/modules/site/manifests/vcs_work.pp
#
# puppet-vcsrepo sucks.  despite the popularity of git and the fact
# that only git is officially supported, there is a two-year old bug
# where this module will fetch on the network every time provisioning
# happens, regardless of whether the repo already exists on the correct
# branch.  below you can find an example of how to use the git module to
# effect clones.  note that the git module does not support "user", so
# don't forget to chown the repo afterwards if you want a non-root user.
#
class site::vcs_work{
 # git::repo{'puppet-git':
 #   path   => '/tmp/puppet-git',
 #   branch => 'master',
 #   ##source => 'git://example.org/example/repo.git'
 #   source => 'https://github.com/nesi/puppet-git.git'
 # }-> exec {'chown -R vagrant:vagrant /tmp/pg':}
}
