# default.pp
#
node default {
  Exec { path => "/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/bin:/usr/local/sbin"}
  stage { first: before => Stage[main] }
  stage { last: require => Stage[main] }

  class{'site::update_apt': stage => first }
  class{'site::configuration': stage => last }

  class { "nginx":
    source_dir       => "puppet:///modules/site/nginx",
    source_dir_purge => false,
  }
  include core::basic_dev
  include core::toybox

  if $vagrant_provision_xwin {
    include core::xwindows
  }

  if $vagrant_provision_neo {
    # see https://github.com/opencredo/neo4j-puppet
    include neo
    exec {
      'install-neo-python':
        require => Package['python-pip'],
        command => 'pip install neo4j-embedded',
        unless  => 'pip freeze|grep neo4j-embedded'
    }
  }
  #include site::vcs_work
}
