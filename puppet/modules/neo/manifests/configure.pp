class neo::configure {

  # Resource defaults
  Exec { path => '/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/bin' }

  require neo::params

  exec {
    'configure-network-interface':
      onlyif  => "grep '#org.neo4j.server.webserver.address=0.0.0.0' ${neo::params::installationdir}/${neo::params::neoversion}/conf/neo4j-server.properties",
      command => "sed -i -e s/'#org.neo4j.server.webserver.address=0.0.0.0'/'org.neo4j.server.webserver.address=0.0.0.0'/g ${neo::params::installationdir}/${neo::params::neoversion}/conf/neo4j-server.properties";

    'configure-ulimit':
      unless  => "grep \"ulimit -n ${neo::params::ulimitn} && checklimits\" ${neo::params::installationdir}/${neo::params::neoversion}/bin/neo4j",
      command => "sed -i -e \'s/checklimits/ulimit -n ${neo::params::ulimitn} \\&\\& checklimits/g\' ${neo::params::installationdir}/${neo::params::neoversion}/bin/neo4j";
  }

}
