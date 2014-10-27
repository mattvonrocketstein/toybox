class neo::install {

	# Resource defaults
	Exec { path => '/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin' }

	require neo::params
	
	package {
		"${neo::params::jreinstaller}":
			ensure	=> installed;
	}
	
	file {
		"${neo::params::installationdir}":
			ensure	=> directory;
		"${neo::params::installationdir}/${neo::params::binpackage}":
			require	=> File["${neo::params::installationdir}"],
			source	=> "${neo::params::tmpdir}/${neo::params::binpackage}";
	}
	
	exec {
		'extract-bin-package':
			require	=> File["${neo::params::installationdir}/${neo::params::binpackage}"],
			unless	=> "test -d ${neo::params::installationdir}/${neo::params::neoversion}",
			cwd		=> "${neo::params::installationdir}",
			command	=> "tar -zxvf ${neo::params::binpackage}";
		
		'install-neo4j':
			require	=> [ User["${neo::params::neouser}"], Exec['extract-bin-package']],
			unless	=> "test -L /etc/init.d/neo4j-service",
			command	=> "${neo::params::installationdir}/${neo::params::neoversion}/bin/neo4j -u ${neo::params::neouser} -h install"
	}
	
	user {
		"${neo::params::neouser}":
			ensure	=> present;
	}
	
	group {
		'puppet':
			ensure	=> present;
	}	

}