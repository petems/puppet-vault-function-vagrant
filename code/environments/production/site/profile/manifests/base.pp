# common class that gets applied to all nodes
# See: "code/environments/production/hieradata/common.yaml"
# It:
#  - configures /etc/hosts entries
#  - makes sure puppet is installed and running
#  - makes sure mcollective + client is installed and running
#
class profile::base {

  host { 'puppet.vm':
    ip => '10.13.38.2',
  }

  host { 'vault.vm':
    ip => '10.13.38.3',
  }

  host { 'node1.vm':
    ip => '10.13.38.4',
  }

  package { 'puppet-agent':
    ensure => installed,
  }

  service { 'puppet':
    ensure  => running,
    enable  => true,
    require => Package['puppet-agent'],
  }

}
