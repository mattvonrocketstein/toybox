exec { "update_apt_for_logstash":
    command => "(echo 'deb http://packages.elasticsearch.org/logstash/1.4/debian stable main' | sudo tee /etc/apt/sources.list.d/logstash.list) && sudo apt-get update",
    creates => "/etc/apt/sources.list.d/logstash.list"
}
#package { 'logstash=1.4.2-1-2c0f5a1': 
#    ensure => present,
#    install_options => '--force-yes',
#    require => Exec['update_apt_for_logstash'],
#}
exec { "install_logstash":
  command => "sudo apt-get install -y --force-yes logstash=1.4.2-1-2c0f5a1",
}
#class { "logstash":
#  install             => "source",
#  install_source      => "https://download.elasticsearch.org/logstash/logstash/logstash-1.3.3-flatjar.jar",
#  version => '1.3.3',
#  template => "site/logstash.conf.erb",
#}
