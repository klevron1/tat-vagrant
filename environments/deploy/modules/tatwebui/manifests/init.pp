# class: tatwebui
#   Install and configure tatwebui
class tatwebui (
  $tatwebui_server = 'localhost',
  $tatwebui_port = 8000,
  $tatwebui_scheme = 'http',
  $tat_server = 'localhost',
  $tat_port = 8080,
  $tat_scheme = 'http',
  $install_path = '/opt/tatwebui',
) {
  package { 'git':
    ensure   => installed,
    provider => 'yum',
  }

  # Install Nodejs and required packages
  package { 'epel-release':
    ensure   => installed,
    provider => 'yum',
  }

  class { '::nodejs':
    manage_package_repo       => false,
    nodejs_dev_package_ensure => 'present',
    npm_package_ensure        => 'present',
    require                   => [ Package['epel-release'], Package['git'] ],
  }

  package { 'bower':
    ensure   => present,
    provider => 'npm',
  }

  package { 'grunt-cli':
    ensure   => present,
    provider => 'npm',
  }

  vcsrepo {'/opt/tatwebui':
    ensure   => present,
    provider => git,
    source   => 'git://github.com/ovh/tatwebui.git',
    owner    => 'vagrant',
    require  => [ Package['bower'], Package['grunt-cli'] ]
  }

  file { 'client/config.json':
    ensure  => file,
    path    => "${install_path}/client/src/assets/config.json",
    owner   => 'vagrant',
    group   => 'vagrant',
    mode    => '0644',
    content => template('tatwebui/client/config.json.erb'),
    require => Vcsrepo['/opt/tatwebui'],
  }

  file { 'client/plugin.tpl.json':
    ensure  => file,
    path    => "${install_path}/client/plugin.tpl.json",
    owner   => 'vagrant',
    group   => 'vagrant',
    mode    => '0644',
    content => template('tatwebui/client/plugin.tpl.json.erb'),
    require => Vcsrepo['/opt/tatwebui'],
  }

  file { 'client/custom.plugin.tpl.json':
    ensure  => file,
    path    => "${install_path}/client/custom.plugin.tpl.json",
    owner   => 'vagrant',
    group   => 'vagrant',
    mode    => '0644',
    content => '{}',
    require => Vcsrepo['/opt/tatwebui'],
  }

  file { 'server/config.json':
    ensure  => file,
    path    => "${install_path}/server/app/config.json",
    owner   => 'vagrant',
    group   => 'vagrant',
    mode    => '0644',
    content => template('tatwebui/server/config.json.erb'),
    require => Vcsrepo['/opt/tatwebui'],
  }

  exec { 'tatwebui release':
    command => 'cd /opt/tatwebui && make release',
    user    => 'vagrant',
    path    => '/usr/bin:/usr/sbin:/bin',
    onlyif  => ['test ! -d /opt/tatwebui/.dist'],
    require => [ File['client/config.json'],
                  File['client/plugin.tpl.json'],
                  File['client/custom.plugin.tpl.json'],
                  File['server/config.json']
                ],
  }

  service { 'tatwebui':
    ensure   => running,
    provider => 'base',
    start    => 'su - vagrant -c "cd /opt/tatwebui && make run" &',
    stop     => 'pkill -o node',
    status   => 'pgrep -o node > /dev/null',
    require  => Exec['tatwebui release'],
  }
}