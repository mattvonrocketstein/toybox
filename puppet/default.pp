# default.pp
#
# puppet/modules/core/manifests/toybox.pp
#
class toybox1{

  package { 'mongodb':
    ensure => installed,
  }

  mongodb_database { 'testdb':
    ensure  => present,
    tries   => 10,
    require => Package['mongodb']
  }

  class { 'rabbitmq':
    service_manage    => true,
    delete_guest_user => false
  }

  rabbitmq_user { 'admin':
    admin    => true,
    password => 'admin',
  }

  package{'celeryd':
    ensure => installed,
  }
  python::pip { 'flower==0.7.3' :
    pkgname       => 'flower==0.7.3',
    timeout       => 1800,
  }
  #exec { 'sudo /usr/bin/pip install flower==0.7.3':
  #  require => [
  #    Package['celeryd'],
  #    Package['python-pip'],],
  #  unless  => 'pip freeze | grep "flower==0.7.3"'
  #}

  # fix a bug where ubuntu installs an older version, or
  # celery will segfault into an otherwise silent error
  python::pip {'librabbitmq==1.5.2':
    pkgname => "librabbitmq==1.5.2",
    timeout => 1800,
    require => [
      Package['celeryd'],
      Package['python-pip']],
  }
  #exec { 'sudo /usr/bin/pip install librabbitmq==1.5.2':
  #  require => [
  #    Package['celeryd'],
  #    Package['python-pip']],
  #  unless  => 'pip freeze | grep "librabbitmq==1.5.2"'
  #}

  exec { 'sudo gem install genghisapp':
    require => [ Package['gem'], Package['ruby-dev']],
    unless  => 'gem list|grep "genghisapp"'
  }
  exec { 'sudo gem install bson_ext -v 1.9.2':
    require => [ Package['gem'], Package['ruby-dev']],
    unless  => 'gem list|grep "bson_ext (1.9.2)"'
  }
  # see https://forge.puppetlabs.com/proletaryo/supervisor
  class { 'supervisor':
    include_superlance      => true,
    enable_http_inet_server => true,
  }

  $fcmd='celery flower --broker=amqp://guest:guest@localhost:5672// --port=5555'
  supervisor::program { 'flower':
    ensure  => present,
    enable  => true,
    command => $fcmd,
  }
  $gcmd='genghisapp --foreground --port 5556'
  supervisor::program { 'genghisapp':
    ensure      => present,
    enable      => true,
    command     => $gcmd,
    environment => 'HOME=/home/vagrant',
  }
}

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

  include jpackage
  include core::basic_dev
  include toybox1
  include site::elk_stack
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
