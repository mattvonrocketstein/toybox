# default.pp
#
node default {
  Exec { path => '/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/bin:/usr/local/sbin'}
  stage { 'first': before => Stage[main] }
  stage { 'last': require => Stage[main] }

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
  file { '/etc/logstash/conf.d/logstash.conf':
    ensure  => file,
    content => template('site/logstash.conf.erb'),
  }
  service { 'logstash':
      ensure    => running,
      enable    => true,
      subscribe => File['/etc/logstash/conf.d/logstash.conf'],
    }
  include core::basic_dev
  include core::toybox
  include site::my_code

  # requires java, which is installed by neo
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


  class { 'kibana':
    install_destination => '/opt/kibana',
    elasticsearch_url   => "http://localhost:9200",
    version             => "3.0.1",
  }

  class { 'elasticsearch':
    datadir     => '/opt/elasticsearch-data',
    package_url => 'https://download.elasticsearch.org/elasticsearch/elasticsearch/elasticsearch-1.2.1.deb'
  }
exec {
  'ES-at-boot':
    require => Package['elasticsearch'],
    command => 'sudo update-rc.d elasticsearch defaults 95 10'
}

exec { "update_apt_for_logstash":
    command => "(echo 'deb http://packages.elasticsearch.org/logstash/1.4/debian stable main' | sudo tee /etc/apt/sources.list.d/logstash.list) && sudo apt-get update",
    creates => "/etc/apt/sources.list.d/logstash.list"
}
#package { 'logstash=1.4.2-1-2c0f5a1': 
#    ensure => present,
#    install_options => '--force-yes',
#    require => Exec['update_apt_for_logstash'],
#}
exec { "install_logstash":
  command => "sudo apt-get install -y --force-yes logstash=1.4.2-1-2c0f5a1",
}
#class { "logstash":
#  install             => "source",
#  install_source      => "https://download.elasticsearch.org/logstash/logstash/logstash-1.3.3-flatjar.jar",
#  version => '1.3.3',
#  template => "site/logstash.conf.erb",
#}

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
