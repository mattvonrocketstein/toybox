# puppet/modules/core/manifests/basic_dev.pp
class core::basic_dev{

  $basic_dev_misc_tools = ['tree','nmap', 'screen', 'ack-grep']
  $basic_dev_ruby_base = ['ruby', 'ruby-dev', 'gem']
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
