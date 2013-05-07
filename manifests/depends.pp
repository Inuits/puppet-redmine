class redmine::depends {
  package {
    redmine:
      ensure    => $::redmine::version,
      name      => $::operatingsystem ? {
        Centos    => 'redmine',
        Debian    => 'redmine',
        archlinux => 'redmine_client',
      },
      provider  => $::operatingsystem ? {
        default => "gem",
        Centos  => 'yum',
        Debian  => "apt",
      },
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
