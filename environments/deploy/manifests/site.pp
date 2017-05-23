$tat_version    = '5.2.2'
$mongod_version = '3.4'

# Install tatcli
class { '::tatserver::tatcli':
  install_path => '/opt',
  tat_version  => $tat_version,
}

# Install and configure tatserver
class { '::tatserver':
  # Not used currently
  # tat_server     => 'localhost',
  # tat_port       => 8080,
  # tat_scheme     => 'http',
  install_path   => '/opt',
  mongod_version => $mongod_version,
  tat_version    => $tat_version,
}

# Install and configure tatwebui
class { '::tatwebui':
  tatwebui_server => 'localhost',
  tatwebui_port   => 8000,
  tatwebui_scheme => 'http',
  tat_server      => 'localhost',
  tat_port        => 8080,
  tat_scheme      => 'http',
  install_path    => '/opt/tatwebui',
  require         => Class['::tatserver'],
}