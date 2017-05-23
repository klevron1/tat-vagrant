# class: tatserver::tatcli
#   Install and configure tatcli
class tatserver::tatcli (
  $install_path = '/opt',
  $tat_version = '5.5.2',
) {
  # Download and install the tat cli binary
  exec { 'download tat cli':
    command => "curl -L https://github.com/ovh/tat/releases/download/v${tat_version}/tatcli-linux-amd64 > ${install_path}/tatcli-linux-amd64",
    path    => '/usr/bin:/usr/sbin:/bin',
    onlyif  => ["test ! -f ${install_path}/tatcli-linux-amd64"],
  }

  file { 'tat cli':
    ensure  => file,
    name    => "${install_path}/tatcli-linux-amd64",
    mode    => '0755',
    owner   => 'root',
    require => Exec['download tat cli'],
  }

  file { 'tat cli link':
    ensure  => link,
    name    => "${install_path}/tatcli",
    target  => "${install_path}/tatcli-linux-amd64",
    owner   => 'root',
    require => File['tat cli'],
  }
}