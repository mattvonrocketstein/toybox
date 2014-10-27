# puppet/modules/core/manifests/curl.pp
class core::curl{
  package{'curl':
    ensure => installed,
  }
}
