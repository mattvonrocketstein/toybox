# puppet/modules/site/manifests/update_apt.pp
class site::update_apt {
  exec{'apt-get update':
    command => '/usr/bin/apt-get update',
    onlyif  => "/bin/sh -c '[ ! -f /var/cache/apt/pkgcache.bin ] || /usr/bin/find /etc/apt/* -cnewer /var/cache/apt/pkgcache.bin | /bin/grep . > /dev/null'",
}
}
