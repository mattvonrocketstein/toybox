# default.pp
#
define print() {
   notice("The value is: '${name}'")
}

class xwindows{
  $xwindows_xwin_base=['xinit']
  $xwindows_wm_utils = ['xmonad', 'xclip', 'dmenu','gmrun', 'stalonetray']
  $xwindows_dev_tools = ['emacs23']
  $xwindows_misc = ['chromium-browser']
  package { $xwindows_xwin_base: ensure => installed}
  package { $xwindows_wm_utils: ensure => installed}
  package { $xwindows_dev_tools: ensure => installed}
  package { $xwindows_misc: ensure => installed}
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

  python::requirements { 'test requirements' :
    virtualenv => '/vagrant/guest_venv',
    owner      => 'vagrant',
    group      => 'vagrant',
    requirements => '/vagrant/tests/requirements.txt',
  }

  python::requirements { 'demo requirements' :
    virtualenv => '/vagrant/guest_venv',
    owner      => 'vagrant',
    group      => 'vagrant',
    requirements => '/vagrant/demos/requirements.txt',
  }
}

class elk_stack {

  class { 'kibana':
    install_destination => '/opt/kibana',
    elasticsearch_url   => "http://localhost:9200",
    version             => "3.0.1",
    } ->
    file { '/opt/kibana/kibana/app/dashboards/toybox.json':
      ensure  => file,
      content => template('site/toybox_kibana_dashboard.json.erb'),
    }

    class { 'elasticsearch':
      datadir     => '/opt/elasticsearch-data',
      package_url => 'https://download.elasticsearch.org/elasticsearch/elasticsearch/elasticsearch-1.2.1.deb'
      }->
      exec {
        'ES-at-boot':
          require => Package['elasticsearch'],
          command => 'sudo update-rc.d elasticsearch defaults 95 10'
          }->
          exec {
            'install-kopf':
              require => Package['elasticsearch'],
              command => "sudo /usr/share/elasticsearch/bin/plugin --install lmenezes/elasticsearch-kopf",
              unless=>"sudo /usr/share/elasticsearch/bin/plugin --list|grep kopf"}

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
                }
}

class basic_dev{

  #$basic_dev_misc_tools = ['sysvbanner', 'ack-grep', 'mosh', 'tree','nmap', 'screen', 'sloccount', 'unzip', 'sshfs', 'htop']
  #print{$toybox_extra_packages: }
  $basic_dev_misc_tools = parsejson($toybox_extra_packages)
  $basic_dev_ruby_base = ['ruby', 'ruby-dev', 'gem']
  $basic_dev_scala_base = ['scala']

  package {$basic_dev_misc_tools:ensure => installed}
  package {$basic_dev_ruby_base:ensure => installed}

  class { git:
    svn => 'absent',
    gui => 'absent',
  }

  class { 'python' :
    version    => 'system',
    pip        => true,
    dev        => true,
    virtualenv => true,
    gunicorn   => false,
  }
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
class toybox1 {

  package { 'mongodb':
    ensure => installed,
  }

  mongodb_database { 'testdb':
    ensure  => present,
    tries   => 10,
    require => Package['mongodb']
  }


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

  file { '/etc/motd':
    ensure  => file,
    content => template('site/motd.erb'),
  }

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
  }


  include basic_dev
  include toybox1
  include my_code

  if $toybox_provision_java {
    notice("install_java")
    include install_java
  }
  if $toybox_provision_rabbit {
    notice("install_rabbit")
    include install_rabbit
  }
  if $toybox_provision_xwin {
    include xwindows
  }
  if $toybox_provision_elasticsearch{
    notice("install_elk")
    include elk_stack
  }

  if $toybox_provision_neo {
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
}
