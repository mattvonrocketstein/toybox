# puppet/modules/core/manifests/basic_dev.pp
class core::basic_dev{
  class{git:
    svn => 'absent',
    gui => 'absent',
  }
  #$basic_dev_vcs = ['git']
  #package { $basic_dev_vcs:ensure => installed}

  $basic_dev_misc_tools = ['tree','nmap', 'screen', 'ack-grep']
  $basic_dev_python_base = ['python2.7', 'python-dev',
                            'python-pip', 'python-virtualenv']
  $basic_dev_ruby_base = ['ruby', 'ruby-dev', 'gem']
  package {$basic_dev_misc_tools:ensure => installed}
  package {$basic_dev_python_base:ensure => installed}
  package {$basic_dev_ruby_base:ensure => installed}
}
