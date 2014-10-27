# bah
class site::vcs_work{
vcsrepo { '/tmp/foo':
    ensure   => latest,
    provider => git,
    source   => 'https://github.com/aubricus/vagrant-puppet-boilerplate.git',
    require  => File['/tmp/foo'],
    revision => 'master',
    force    => true,
}
}
