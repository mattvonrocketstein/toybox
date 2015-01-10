# default.pp
#
class jpackage {
  case $operatingsystem {
    /(Ubuntu|Debian)/: {
      $jreinstaller = 'default-jre'
    }
    /(RedHat|CentOS|Fedora)/: {
      $jreinstaller = 'java-1.6.0-openjdk'
    }
  }
  package {
    "${jreinstaller}":
      ensure  => installed;
  }
}

node default {
  Exec { path => '/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/bin:/usr/local/sbin'}
  stage { 'first': before => Stage[main] }
  stage { 'last': require => Stage[main] }
  #class { "zources": stage => "first"; }

  class{'site::update_apt': stage => first }
  class{'site::configuration': stage => last }

  class { 'nginx':
    source_dir       => 'puppet:///modules/site/nginx_conf',
    source_dir_purge => false,
  }
  file { '/opt/www':
    ensure  => directory,
    path    => '/opt/www',
    require => File['/etc/nginx/nginx.conf'],
    source  => 'puppet:///modules/site/www',
    recurse => true,
  }

  file { '/etc/motd':
    ensure  => file,
    content => template('site/motd.erb'),
  }
  #service { 'logstash':
    #    ensure    => running,
    #    enable    => true,
    #    subscribe => File['/etc/logstash/conf.d/logstash.conf'],
    #  }
    #include zources
    include jpackage
    include core::basic_dev
    include site::logstash
    include core::toybox
    include site::my_code

    # requires java, which is installed by neo

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
