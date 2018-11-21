# profile to deploy a puppet vault_server

class profile::vault_server {

  firewall { '8200 accept - vault':
    dport  => '8200',
    proto  => 'tcp',
    action => 'accept',
  }

  file { '/mnt/vault/':
    ensure => directory,
    owner  => 'vault',
    group  => 'vault',
  }

  file { '/etc/vault/keys':
    ensure => directory,
    owner  => 'vault',
    group  => 'vault',
  }

  file { '/etc/vault/keys/ca_cert.pem':
    ensure => file,
    owner  => 'vault',
    group  => 'vault',
    source => "/etc/puppetlabs/puppet/ssl/certs/ca.pem",
  }

  file { '/etc/vault/keys/vaultvm_cert.pem':
    ensure => file,
    owner  => 'vault',
    group  => 'vault',
    source => "/etc/puppetlabs/puppet/ssl/certs/vault.vm.pem",
  }

  file { '/etc/vault/keys/vaultvm_key.pem':
    ensure => file,
    owner  => 'vault',
    group  => 'vault',
    source => "/etc/puppetlabs/puppet/ssl/private_keys/vault.vm.pem",
  }

  class { '::vault':
    manage_storage_dir => true,
    storage => {
      file => {
        path => '/mnt/vault/data',
      },
    },
    listener => {
      tcp => {
        'tls_disable'        => false,
        'address'            => '0.0.0.0:8200',
        'tls_client_ca_file' => '/etc/vault/keys/ca_cert.pem',
        'tls_cert_file'      => '/etc/vault/keys/vaultvm_cert.pem',
        'tls_key_file'       => '/etc/vault/keys/vaultvm_key.pem'
      },
    },
    version   => '0.11.5',
    enable_ui => true,
  }

  file { '/usr/bin/vault':
    ensure => link,
    target => '/usr/local/bin/vault',
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
  }

  file { '/tmp/terraform.zip':
    ensure => file,
    source => "https://releases.hashicorp.com/terraform/0.11.10/terraform_0.11.10_linux_amd64.zip"
  } ->
  exec {'unzip_terraform':
    path => '/usr/bin',
    command => 'sudo unzip /tmp/terraform.zip -d /usr/bin',
    creates => '/usr/bin/terraform',
  }

}
