# puppet/modules/site/manifests/my_code.pp
#
# puppet-vcsrepo sucks.  despite the popularity of git and the fact
# that only git is officially supported, there is a two-year old bug
# where this module will fetch on the network every time provisioning
# happens, regardless of whether the repo already exists on the correct
# branch.  below you can find an example of how to use the git module to
# effect clones.  note that the git module does not support "user", so
# don't forget to chown the repo afterwards if you want a non-root user.
#
class site::my_code{
  # GIT CLONE EXAMPLE:
  #
  # git::repo{'puppet-git':
  #   path   => '/tmp/puppet-git',
  #   branch => 'master',
  #   ##source => 'git://example.org/example/repo.git'
  #   source => 'https://github.com/nesi/puppet-git.git'
  # }-> exec {'chown -R vagrant:vagrant /tmp/pg':}

  # PYTHON PIP EXAMPLE (installation is system-wide unless venv is given)
  python::pip { 'fabric' :
    pkgname       => 'fabric',
    timeout       => 1800,
  }

  # PYTHON VENV EXAMPLE (needed to run tests, see toybox README.md)
  #
  python::virtualenv { '/vagrant/guest_venv' :
      ensure       => present,
      version      => 'system',
      systempkgs   => true,
      owner        => 'vagrant',
      group        => 'vagrant',
      requirements => '/vagrant/tests/requirements.txt',
      # proxy        => 'http://proxy.domain.com:3128',
      # distribute   => false,
      # cwd          => '/var/www/project1',
      # timeout      => 0,
  }
}
