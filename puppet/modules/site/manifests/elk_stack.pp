class site::elk_stack{

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