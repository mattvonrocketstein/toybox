#class neo::python {
#
#
#  # Resource defaults
#  Exec { path => '/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin' }
#
#  case $operatingsystem {
#    /(Ubuntu|Debian)/: {
#      package {
#        'python-pip':
#          ensure  => installed;
#      }
#
#      exec {
#        'install-neo-python':
#          require => Package['python-pip'],
#          command => 'pip install neo4j-embedded';
#      }
#    }
#
#  }
#}
