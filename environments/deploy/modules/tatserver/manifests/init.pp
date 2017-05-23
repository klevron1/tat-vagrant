# class: tatserver
#   Install and configure tatserver
class tatserver (
  $tat_server = 'localhost',
  $tat_port = 8080,
  $tat_scheme = 'http',
  $install_path = '/opt',
  $mongod_version = '3.4',
  $tat_version = '5.5.2',
) {
  # Download, install and start the tat server binary
  exec { 'download tat':
    command => "curl -L https://github.com/ovh/tat/releases/download/v${tat_version}/tat-linux-amd64 > ${install_path}/tat-linux-amd64",
    path    => '/usr/bin:/usr/sbin:/bin',
    onlyif  => ["test ! -f ${install_path}/tat-linux-amd64"],
  }

  file { 'tat server':
    ensure  => file,
    name    => "${install_path}/tat-linux-amd64",
    mode    => '0744',
    owner   => 'root',
    require => Exec['download tat'],
  }

  service { 'tat service':
    ensure   => running,
    provider => 'base',
    start    => "${install_path}/tat-linux-amd64 --no-smtp > /var/log/tat.log 2>&1 &",
    stop     => 'pkill tat-linux-amd64',
    status   => 'pgrep tat-linux-amd64 > /dev/null',
    require  => [ File['tat server'], Service['mongod'] ],
  }

  # Mongodb community edition
  file { "/etc/yum.repos.d/mongodb-org-${mongod_version}.repo":
    ensure  => file,
    content => "[mongodb-org-${mongod_version}]
name=MongoDB Repository
baseurl=https://repo.mongodb.org/yum/redhat/\$releasever/mongodb-org/${mongod_version}/x86_64/
gpgcheck=1
enabled=1
gpgkey=https://www.mongodb.org/static/pgp/server-${mongod_version}.asc
",
    before  => Package['mongodb-org']
  }

  package { 'mongodb-org':
    ensure   => installed,
    provider => 'yum',
  }

  service { 'mongod':
    ensure   => running,
    provider => 'redhat',
    require  => Package['mongodb-org']
  }
}
