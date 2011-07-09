class redmine::depends {
	case $operatingsystem {
		Centos: { include redmine::depends::centos }
		Debian: { include redmine::depends::debian }
	}

	package { redmine:
		ensure => installed,
		name => $operatingsystem ? {
			Centos => 'redmine_client',
			Debian => 'redmine',
		},
		provider => $operatingsystem ? {
			Centos => "gem",
			Debian => "apt",
		},
		before => Exec["config_redmine_mysql_bootstrap"],
#		require => [ User['redmine'], Class['apache::packages', 'mysql::packages'] ],
	}

	package { 'gem_i18n':
#		ensure => '0.4.2',
		name => 'i18n',
		provider => gem,
		before => Package['gem_rails'],
	}

	package { 'gem_mysql':
		ensure => installed,
		name => 'ruby-mysql',
		provider => gem,
		require => Package['gem_i18n'],
	}

	package { 'gem_rack':
		ensure => '1.1.1',
		name => 'rack',
		provider => gem,
		before => Package['gem_rails'],
	}

	package { 'gem_hoe':
		ensure => installed,
		name => 'hoe',
		provider => gem,
		before => Package['gem_rails'],
	}

	package { 'gem_rails':
		ensure => 2.3.11,
		name => 'rails',
		provider => gem,
		before => Exec['config_redmine_mysql_bootstrap'],
	}

	package { 'curl-devel':
		ensure => installed,
		name => $operatingsystem ? {
			Centos => 'curl-devel',
			Debian => 'libcurl4-openssl-dev',
		},
	}
}

class redmine::depends::debian {
	@package { 'redmine-mysql':
		ensure => installed,
		require => Package['redmine'],
	}

	if $operatingsystem == 'Debian' {
		realize(Package['redmine-mysql'])
	}
}

class redmine::depends::centos {
	exec { 'redmine_sources':
		path => '/bin:/usr/bin',
		cwd => '/usr/share',
		command => '/bin/sh -c "wget http://rubyforge.org/frs/download.php/74419/redmine-1.1.2.tar.gz;tar zxvf redmine-1.1.2.tar.gz;mv redmine-1.1.2 redmine;chmod -R a+rx /usr/share/redmine/public/;cd /usr/share/redmine;chmod -R 755 files log tmp"',
		unless => '/usr/bin/test -d /usr/share/redmine',
	}

#	file { '/usr/share/redmine-1.1.3.tar.gz':
#		ensure => present,
#		source => 'puppet:///modules/redmine/redmine.tar.gz',
#	}

#	exec { 'extract_redmine':
#		path => '/bin:/usr/bin',
#		command => 'cd /usr/share && tar xzvf redmine-1.1.3.tar.gz redmine && touch /usr/share/redmine/redmine.puppet',
#		require => File['/usr/share/redmine-1.1.3.tar.gz'],
#		unless => '/usr/bin/test -f /usr/share/redmine/redmine.puppet',
#	}

	file { '/etc/redmine':
		ensure => directory,
		owner => root,
		group => root,
		mode => 0755,
		before => File['/etc/redmine/default'],
	}

	file { '/etc/redmine/default':
		ensure => directory,
		owner => $redmine_id,
		group => $redmine_id,
		mode => 0755,
		before => Class['redmine::config'],
#		require => Exec['redmine_sources'],
	}
}
