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
  $tatwebui_user = 'tatwebui',
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

  group { $tatwebui_user:
    ensure => present,
  }

  user { $tatwebui_user:
    ensure  => present,
    home    => $install_path,
    require => Group[$tatwebui_user]
  }

  vcsrepo { $install_path:
    ensure   => present,
    provider => git,
    source   => 'git://github.com/ovh/tatwebui.git',
    owner    => $tatwebui_user,
    require  => [ Package['bower'], Package['grunt-cli'], User[$tatwebui_user] ]
  }

  file { 'client/config.json':
    ensure  => file,
    path    => "${install_path}/client/src/assets/config.json",
    owner   => $tatwebui_user,
    group   => $tatwebui_user,
    mode    => '0644',
    content => template('tatwebui/client/config.json.erb'),
    require => Vcsrepo[$install_path],
  }

  file { 'client/plugin.tpl.json':
    ensure  => file,
    path    => "${install_path}/client/plugin.tpl.json",
    owner   => $tatwebui_user,
    group   => $tatwebui_user,
    mode    => '0644',
    content => template('tatwebui/client/plugin.tpl.json.erb'),
    require => Vcsrepo[$install_path],
  }

  file { 'client/custom.plugin.tpl.json':
    ensure  => file,
    path    => "${install_path}/client/custom.plugin.tpl.json",
    owner   => $tatwebui_user,
    group   => $tatwebui_user,
    mode    => '0644',
    content => '{}',
    require => Vcsrepo[$install_path],
  }

  file { 'server/config.json':
    ensure  => file,
    path    => "${install_path}/server/app/config.json",
    owner   => $tatwebui_user,
    group   => $tatwebui_user,
    mode    => '0644',
    content => template('tatwebui/server/config.json.erb'),
    require => Vcsrepo[$install_path],
  }

  file { 'tatwebui init script':
    ensure  => file,
    path    => '/etc/init.d/tat-webui',
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    content => template('tatwebui/tat-webui.erb'),
    require => Vcsrepo[$install_path],
  }

  exec { 'tatwebui release':
    command => "cd ${install_path} && make release",
    user    => $tatwebui_user,
    path    => '/usr/bin:/usr/sbin:/bin',
    onlyif  => ["test ! -d ${install_path}/.dist"],
    require => [ File['client/config.json'],
                  File['client/plugin.tpl.json'],
                  File['client/custom.plugin.tpl.json'],
                  File['server/config.json']
                ],
  }

  service { 'tat-webui':
    ensure   => running,
    provider => 'redhat',
    require  => [ Exec['tatwebui release'], File['tatwebui init script'] ],
  }
}