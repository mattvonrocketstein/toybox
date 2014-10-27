# puppet/modules/core/manifests/mysql5.pp
class core::mysql5 {
    package { 'mysql-client':
        ensure => installed,
    }

    package { 'mysql-server':
        ensure => installed,
    }

    service { 'mysql':
        ensure  => running,
        name    => 'mysql',
        enable  => true,
        require => Package['mysql-server'],
    }
}
