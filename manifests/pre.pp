class redmine::pre {
  @exec {
    'apt update':
      command => 'apt-get update',
      path    => '/usr/bin';

    'yum update':
      command => 'yum update -y',
      timeout => '0',
      path    => '/usr/bin';
  }

  case $::operatingsystem {
    Centos: {realize(Exec['yum update'])}
    Debian: {realize(Exec['apt update'])}
  }

}
