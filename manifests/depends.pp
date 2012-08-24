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
      before    => Exec["config_redmine_mysql_bootstrap"];
      # require => [ User['redmine'], Class['apache::packages', 'mysql::packages'] ],

    'gem_i18n':
      ensure   => '0.4.2',
      name     => 'i18n',
      provider => gem,
      before   => Package['gem_rails'];

    'gem_mysqlplus':
      ensure   => installed,
      name     => 'mysqlplus',
      provider => gem,
      require  => Package['gem_i18n', 'mysql-dev'];

    'gem_rack':
      ensure    => $::operatingsystem ? {
        default   => '1.1.1',
        Debian    => '1.0.1',
      },
      name      => 'rack',
      provider  => gem,
      before    => Package['gem_rails'];

    'gem_rake':
      ensure   => '0.8.7',
      name     => 'rake',
      provider => 'gem';
/*
    'gem_hoe':
      ensure   => installed,
      name     => 'hoe',
      provider => gem,
      before   => Package['gem_rails'];
*/

    'gem_rails':
      ensure    => $::operatingsystem ? {
        default   => '2.3.11',
        Debian    => '2.3.5',
      },
      name      => 'rails',
      provider  => gem,
      before    => Exec['config_redmine_mysql_bootstrap'];
  }

  if $::operatingsystem =~ /debian/ {
    realize(Package['redmine-mysql'])
  }

  @package { 'redmine-mysql':
    ensure  => installed,
    require => Package['redmine'],
  }

}
