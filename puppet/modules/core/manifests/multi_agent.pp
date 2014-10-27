# puppet/modules/core/manifests/multi_agent.pp
#
class core::multi_agent{

  package { 'mongodb':
    ensure => installed,
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
  exec { 'sudo /usr/bin/pip install flower==0.7.3':
    require => [
      Package['celeryd'],
      Package['python-pip'],
      Package['python-dev'],
      Package['python2.7']],
    unless  => 'pip freeze | grep "flower==0.7.3"'
  }

  # fix a bug where ubuntu installs an older version, or
  # celery will segfault into an otherwise silent error
  exec { 'sudo /usr/bin/pip install librabbitmq==1.5.2':
    require => [
      Package['celeryd'],
      Package['python-pip'],
      Package['python-dev'],
      Package['python2.7']],
    unless  => 'pip freeze | grep "librabbitmq==1.5.2"'
  }

  exec { 'gem install genghisapp':
    require => [ Package['gem'], Package['ruby-dev']],
    unless  => 'gem list|grep "genghisapp"'
  }
  exec { 'gem install bson_ext -v 1.9.2':
    require => [ Package['gem'], Package['ruby-dev']],
    unless  => 'gem list|grep "bson_ext (1.9.2)"'
  }
  # see https://forge.puppetlabs.com/proletaryo/supervisor
  class { 'supervisor':
    include_superlance      => false,
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
  # see https://github.com/opencredo/neo4j-puppet
  include neo
  exec {
    'install-neo-python':
      require => Package['python-pip'],
      command => 'pip install neo4j-embedded',
      unless  => 'pip freeze|grep neo4j-embedded'
  }
}
