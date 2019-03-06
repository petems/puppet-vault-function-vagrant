Vagrant.configure(2) do |config|

  config.vm.define "puppet", primary: true do |puppet|
    puppet.vm.hostname = "puppet.vm"
    puppet.vm.box = "geerlingguy/centos7"
    puppet.vm.box_version = "1.2.12"
    puppet.vm.network "private_network", ip: "10.13.38.2"
    puppet.vm.network :forwarded_port, guest: 8080, host: 8080, id: "puppetdb"

    puppet.vm.synced_folder "code", "/etc/puppetlabs/code"

    puppet.vm.provider :virtualbox do |vb|
      vb.memory = "3072"
    end

    # Used to do initial bootstrap of Puppet master before Vault is ready
    puppet.vm.provision "shell", path: "install_puppet.sh"

    puppet.vm.provision "puppet" do |puppetapply|
      puppetapply.environment = "production"
      puppetapply.environment_path = ["vm", "/etc/puppetlabs/code/environments"]
    end
  end

  config.vm.define "vault", primary: true do |vault|
    vault.vm.hostname = "vault.vm"
    vault.vm.box = "geerlingguy/centos7"
    vault.vm.box_version = "1.2.12"
    vault.vm.network "private_network", ip: "10.13.38.3"
    vault.vm.network :forwarded_port, guest: 8200, host: 8200, id: "vault"

    vault.vm.provision "shell", path: "install_puppet.sh"

    # Run an agent run to check Puppetserver master is running ok
    vault.vm.provision "puppet_server" do |puppet_server|
      puppet_server.puppet_server = "puppet"
      puppet_server.options = "--test"
    end
  end

  config.vm.define "node1", primary: true do |node1|
    node1.vm.hostname = "node1.vm"
    node1.vm.box = "geerlingguy/centos7"
    node1.vm.box_version = "1.2.12"
    node1.vm.network "private_network", ip: "10.13.38.4"

    node1.vm.provision "shell", path: "install_puppet.sh"

    # Run an agent run to check Puppetserver master is running ok
    node1.vm.provision "puppet_server" do |puppet_server|
      puppet_server.puppet_server = "puppet"
      puppet_server.options = "--test"
    end
  end

  config.vm.define "node2", primary: true do |node2|
    node2.vm.hostname = "node2.vm"
    node2.vm.box = "geerlingguy/centos7"
    node2.vm.box_version = "1.2.12"
    node2.vm.network "private_network", ip: "10.13.38.5"

    node2.vm.provision "shell", path: "install_puppet.sh"

    # Run an agent run to check Puppetserver master is running ok
    node2.vm.provision "puppet_server" do |puppet_server|
      puppet_server.puppet_server = "puppet"
      puppet_server.options = "--test"
    end
  end

end
