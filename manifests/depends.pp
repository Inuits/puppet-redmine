class redmine::depends {
  $package_name = $::operatingsystem ? {
    Centos    => 'redmine',
    Debian    => 'redmine',
    archlinux => 'redmine_client',
  }
  $package_provider = $::operatingsystem ? {
    Centos  => 'yum',
    Debian  => 'apt',
    default => 'gem',
  }

  package {
    'redmine':
      ensure    => $::redmine::version,
      name      => $package_name,
      provider  => $package_provider,
      # require => [ User['redmine'], Class['apache::packages', 'mysql::packages'] ],
      before    => Exec['config_redmine_mysql_bootstrap'],
      notify    => Exec[
        'config_redmine_mysql_bootstrap',
        'session_store'
      ];
  }

  if $::operatingsystem =~ /debian/ {
    realize(Package['redmine-mysql'])
  }

  @package { 'redmine-mysql':
    ensure  => installed,
    require => Package['redmine'],
  }

}
