# puppet/modules/core/manifests/apache2.pp
class core::apache2{
  package { 'apache2':
    ensure => installed,
  }

  service { 'apache2':
    ensure     => running,
    enable     => true,
    hasrestart => true,
    require    => Package['apache2'],
  }

  file{'apache.envvars':
    ensure  => present,
    path    => '/etc/apache2/envvars',
    require => Package[apache2],
    source  => 'puppet:///modules/core/apache2/envvars',
    owner   => root,
    group   => root,
    notify  => Service['apache2'],
    mode    => '0644';
  }
}
