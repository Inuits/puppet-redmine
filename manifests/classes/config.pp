class redmine::config {

	file { 'database.yml':
		ensure => present,
		owner => $redmine_id,
		group => $redmine_id,
		path => $operatingsystem ? {
			default => '/usr/share/redmine/config/database.yml',
			Debian => '/etc/redmine/default/database.yml',
		},
		content => template("redmine/database.yml.erb"),
	}

	file { '/var/www/redmine':
		ensure => link,
		target => '/usr/share/redmine/public',
		owner => $redmine_id,
		group => $redmine_id,
	}

	exec { 'config_redmine_mysql_bootstrap':
		environment => 'RAILS_ENV=production',
		path => '/usr:/usr/bin',
		cwd => '/usr/share/redmine',
		provider => shell,
		command => 'rake db:migrate',
		require => Mysql_db[$redmine::production_db],
		notify => Service["$redmine::webserver"];
	}
}
