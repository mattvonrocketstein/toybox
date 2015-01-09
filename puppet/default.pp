# default.pp
#
node default {
  Exec { path => "/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/bin:/usr/local/sbin"}
  stage { first: before => Stage[main] }
  stage { last: require => Stage[main] }

  class{'site::update_apt': stage => first }
  class{'site::configuration': stage => last }


  class { "nginx":
    source_dir       => "puppet:///modules/site/nginx_conf",
    source_dir_purge => false,
  }

  file { '/opt/www':
    path    => '/opt/www',
    ensure  => directory,
    require => File['/etc/nginx/nginx.conf'],
    source  => 'puppet:///modules/site/www',
    recurse => true,

  }

  file { '/etc/motd':
    ensure => file,
    content => template('site/motd.erb'),
  }

  include core::basic_dev
  include core::toybox
  include site::my_code

  include 'kibana'

  class {
    'kibana3':
      config_es_port     => '9201',
      config_es_protocol => 'https',
      config_es_server   => 'es.my.domain',
  }

  if $vagrant_provision_xwin {
    include site::xwindows
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
}
