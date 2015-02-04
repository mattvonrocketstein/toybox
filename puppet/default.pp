# default.pp
#
define print() {
  notice("The value is: '${name}'")
}


# puppet/modules/core/manifests/toybox.pp
#
# puppet-vcsrepo sucks.  despite the popularity of git and the fact
# that only git is officially supported, there is a two-year old bug
# where this module will fetch on the network every time provisioning
# happens, regardless of whether the repo already exists on the correct
# branch.  below you can find an example of how to use the git module to
# effect clones.  note that the git module does not support "user", so
# don't forget to chown the repo afterwards if you want a non-root user.
#
class my_code{
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

  # PYTHON VENV/REQS EXAMPLE
  # this is needed to run tests and demos.
  # see toybox README.md
  python::virtualenv { '/vagrant/guest_venv' :
    ensure       => present,
    version      => 'system',
    systempkgs   => true,
    owner        => 'vagrant',
    group        => 'vagrant',
    # proxy        => 'http://proxy.domain.com:3128',
    # distribute   => false,
    # cwd          => '/var/www/project1',
    # timeout      => 0,
  }
}

class install_xwindows{
  $xwindows_xwin_base=['xinit']
  if($toybox_vagrant_invocation){
    $xwindows_extra = parsejson($toybox_xwin_extra)
  }
  else {
    $xwindows_extra=[]
  }
  package { $xwindows_xwin_base: ensure => installed}
  package { $xwindows_extra: ensure => installed}
}

class install_nginx{
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
}

class install_neo{
  notice("install_neo")
  # see https://github.com/opencredo/neo4j-puppet
  include neo
  exec {
    'install-neo-python':
      require => Package['python-pip'],
      command => 'pip install neo4j-embedded',
      unless  => 'pip freeze|grep neo4j-embedded'
  }
}

class install_kibana {
  class { 'kibana':
    install_destination => '/opt/kibana',
    elasticsearch_url   => "http://localhost:9200",
    version             => "3.0.1",
    } ->
    file { '/opt/kibana/kibana/app/dashboards/toybox.json':
      ensure  => file,
      content => template('site/toybox_kibana_dashboard.json.erb'),
    }
}

class elk_stack {

  include install_kibana

  class { 'elasticsearch':
    datadir     => '/opt/elasticsearch-data',
    package_url => 'https://download.elasticsearch.org/elasticsearch/elasticsearch/elasticsearch-1.2.1.deb'
    }->
    exec {
      'ES-at-boot':
        require => Package['elasticsearch'],
        command => 'sudo update-rc.d elasticsearch defaults 95 10'
        } ->
        exec {
          'install-kopf':
            require => Package['elasticsearch'],
            command => "/usr/share/elasticsearch/bin/plugin --install lmenezes/elasticsearch-kopf",
            unless => "/usr/share/elasticsearch/bin/plugin --list|grep kopf"}

          apt::source { 'lstash':
            #comment           => 'This is the iWeb Debian unstable mirror',
            location          => 'http://packages.elasticsearch.org/logstash/1.4/debian',
            release           => 'stable',
            repos             => 'main',
            #required_packages => 'debian-keyring debian-archive-keyring',
            #key               => '8B48AD6246925553',
            #key_server        => 'subkeys.pgp.net',
            #pin               => '-10',
            #include_src       => true,
            #include_deb       => true

            }->
            exec { 'install_logstash':
              command => 'sudo apt-get install -y --force-yes logstash=1.4.2-1-2c0f5a1',
              #require => Exec['update_apt_for_logstash'],
              }->
              file { '/etc/logstash/conf.d/logstash.conf':
                ensure  => file,
                content => template('site/logstash.conf.erb'),
              }->
              # the scripts installed by default into /etc/init.d/logstash
              # are completely haywire, ignore stop requests, and eat up all
              # cpu.  see this page for more info:
              # http://stackoverflow.com/questions/25867244/100-cpu-usage-after-logstash-install
              # besides, we want to manage it with supervisor anyway
              service { "logstash":
                ensure => "stopped",
                enable => "false",
              }->
              service { "logstash-web":
                ensure => "stopped",
                enable => "false",
              }->
              supervisor::program { 'logstash':
                  ensure      => present,
                  enable      => true,
                  command     => 'sudo /opt/logstash/bin/logstash agent --debug --log /var/log/logstash/logstash.log -f /etc/logstash/conf.d/logstash.conf web --port 9292',
                  environment => 'HOME=/home/vagrant',
                }->
                notify {'finished logstash configuration':}
}

class install_java{
  case $operatingsystem {
    /(Ubuntu|Debian)/: {
      $toybox_jreinstaller = 'default-jre'
    }
    /(RedHat|CentOS|Fedora)/: {
      $toybox_jreinstaller = 'java-1.6.0-openjdk'
    }
  }
  package {
    "${toybox_jreinstaller}":
      ensure  => installed;
  }
}

class install_rabbit{
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

  $fcmd='celery flower --broker=amqp://guest:guest@localhost:5672// --port=5555'
  supervisor::program { 'flower':
    ensure  => present,
    enable  => true,
    command => $fcmd,
  }

  # fix a bug where ubuntu installs an older version, or
  # celery will segfault into an otherwise silent error
  python::pip {'librabbitmq==1.5.2':
    pkgname => "librabbitmq==1.5.2",
    timeout => 1800,
    require => [
                Package['celeryd'],
                Package['python-pip']],
  }
}

class install_genghis {
  exec { 'sudo gem install genghisapp':
    require => [ Package['gem'], Package['ruby-dev']],
    unless  => 'gem list|grep "genghisapp"'
  }-> notify {'finished genghisapp installation':}

  exec { 'sudo gem install bson_ext -v 1.9.2':
    require => [ Package['gem'], Package['ruby-dev']],
    unless  => 'gem list|grep "bson_ext (1.9.2)"'
  }
  $gcmd='genghisapp --foreground --port 5556'
  supervisor::program { 'genghisapp':
    ensure      => present,
    enable      => true,
    command     => $gcmd,
    environment => 'HOME=/home/vagrant',
  }
}

class install_mongo {
  package { 'mongodb':
    ensure => installed,
  }

  mongodb_database { 'testdb':
    ensure  => present,
    tries   => 10,
    require => Package['mongodb']
  }

  if $toybox_provision_genghis { include install_genghis }
}

class toybox1 {

  file { '/etc/motd':
    ensure  => file,
    content => template('site/motd.erb'),
  }

  python::virtualenv { '/opt/toybox' :
    ensure       => present,
    version      => 'system',
    systempkgs   => true,
    owner        => 'vagrant',
    group        => 'vagrant',
    # proxy        => 'http://proxy.domain.com:3128',
    # distribute   => false,
    # cwd          => '/var/www/project1',
    # timeout      => 0,
  }->
  exec {"slash_vagrant":
    command => '/bin/true',
    onlyif => '/usr/bin/test -e /vagrant',
  }
  python::requirements { 'test requirements' :
    virtualenv => '/opt/toybox',
    owner      => 'vagrant',
    require => Exec["slash_vagrant"],
    group      => 'vagrant',
    requirements => '/vagrant/tests/requirements.txt',
  }->
  python::requirements { 'other requirements' :
    virtualenv => '/opt/toybox',
    owner      => 'vagrant',
    group      => 'vagrant',
    require => Exec["slash_vagrant"],
    requirements => '/vagrant/requirements.txt',
  }->
  python::requirements { 'demo requirements' :
    virtualenv => '/opt/toybox',
    owner      => 'vagrant',
    group      => 'vagrant',
    require => Exec["slash_vagrant"],
    requirements => '/vagrant/demos/requirements.txt',
  }->
  exec {"install_toybox_cl":
    command => '/opt/toybox/bin/python setup.py install',
    require => Exec["slash_vagrant"],
    cwd     => '/vagrant',
  }

  # see https://forge.puppetlabs.com/proletaryo/supervisor
  class { 'supervisor':
    include_superlance      => true,
    enable_http_inet_server => true,
  }
}
class update_apt {
  exec{'apt-get update':
    command => '/usr/bin/apt-get update',
    onlyif  => "/bin/sh -c '[ ! -f /var/cache/apt/pkgcache.bin ] || /usr/bin/find /etc/apt/* -cnewer /var/cache/apt/pkgcache.bin | /bin/grep . > /dev/null'",
  }
}
# configured to run the 'last' stage
# e.g., this will run AFTER everything else runs
# place any final config actions here
#
class configuration{}

node default {
  Exec { path => '/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/bin:/usr/local/sbin'}
  stage { 'first': before => Stage[main] }
  stage { 'last': require => Stage[main] }

  class{'update_apt': stage => first }
  class{'configuration': stage => last }

  # section covers basic needs for development
  ##############################################################################
  # note: this is possibly empty, but always passed in if puppet is invoked
  #       by vagrant. the case makes it work correctly with puppet apply
  if $toybox_extra_packages {
      $basic_dev_misc_tools = parsejson($toybox_extra_packages)
      package {$basic_dev_misc_tools:ensure => installed}
  }
  else {
    notify {"no fact found for 'toybox_extra_packages'": }
  }



  # basic ruby base is not optional: used by genghis etc
  $basic_dev_ruby_base = ['ruby', 'ruby-dev', 'gem']
  package {$basic_dev_ruby_base:ensure => installed}

  # git install is not optional: too useful to warrant a switch
  class { git:
    svn => 'absent',
    gui => 'absent',
  }

  # python install is not optional: too useful to warrant a switch
  class { 'python' :
    version    => 'system',
    pip        => true,
    dev        => true,
    virtualenv => true,
    gunicorn   => false,
  }

  #
  ##############################################################################
  include toybox1
  include my_code

  if $toybox_vagrant_invocation {
    if $toybox_provision_nginx { include install_nginx }
    if $toybox_provision_mongo { include install_mongo }
    if $toybox_provision_rabbit { include install_rabbit }
    if $toybox_provision_xwin { include install_xwindows }
    if $toybox_provision_java { include install_java }
    if $toybox_provision_neo { include install_neo}
    if $toybox_provision_elasticsearch{ include elk_stack }
  }
  else {
    include install_nginx
    include install_mongo
    include install_rabbit
    include install_xwindows
    include install_java
    include install_neo
    include elk_stack
  }
}
