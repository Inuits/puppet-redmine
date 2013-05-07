class redmine::config {
  file {
    'database.yml':
      ensure  => present,
      owner   => $redmine::user,
      group   => $redmine::group,
      path    => $::operatingsystem ? {
        default => '/usr/share/redmine/config/database.yml',
        Debian  => '/etc/redmine/default/database.yml',
      },
      content => template("redmine/database.yml.erb");

    'configuration.yml':
      ensure  => present,
      owner   => $redmine::user,
      group   => $redmine::group,
      path    => "$redmine::home/config/configuration.yml",
      content => template('redmine/configuration.yml.erb');
  }

  exec {
    'chown redmine':
      command  => "chown -R ${redmine::user}:${redmine::group} ${redmine::home}",
      unless   => "find ${::redmine::home} ! -user ${::redmine::user} -or ! -group ${::redmine::group}",
      provider => 'shell';
  }

  exec {
    'session_store':
      path        => '/opt/ruby1.8/bin:/bin:/usr/bin',
      cwd         => '/usr/share/redmine/public',
      provider    => 'shell',
      command     => 'rake generate_session_store',
      refreshonly => true,
      require     => Class['redmine::depends'];
  }
}
