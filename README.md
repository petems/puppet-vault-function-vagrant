# puppet-hiera-vault-vagrant

> Note: This is a heavily modified form of https://github.com/roman-mueller/puppet4-sandbox but focused on demo-ing vault_lookup with Puppet certs for authentication

This is a sandbox repository to show how HashiCorp's Vault can be used for the retrival of secrets on an agent in a Puppet environment.

In the Vagrantfile there are 3 VMs defined:

A puppetserver ("puppet"), a vault instance ("vault") and a puppet node ("node1") all running CentOS 7.0.

Classes get configured via hiera (see `code/environments/production/hieradata/*`).

# Requirements and Setup

* Vagrant 2.X (Works with older but easier to use newer!)
* VirtualBox
* The puppetserver VM is configured to use 3GB of RAM
* The node is using the default (usually 512MB).
* A shell provisioner ("install_puppet.sh") which installs the Puppet 6 Yum repos and updates `puppet-agent` before running it for the first time. That way newly spawned Vagrant environments will always use the latest available version.
* There is no DNS server running in the private network, all nodes have each other in their `/etc/hosts` files.

# Usage

After cloning the repository make sure the submodules are also updated:

```
$ git clone https://github.com/petems/puppet-vault-function-vagrant
$ cd puppet-vault-function-vagrant
$ git submodule update --init --recursive
```

Whenever you `git pull` this repository you should also update the submodules again.

Now you can simply run `vagrant up puppet` to get a fully set up puppetserver.

The `code/` folder will be a synced folder and gets mounted to `/etc/puppetlabs/code` inside the VM.

# Configuring Vault

Vault gets installed and started by default on the `vault` node.

The local port 8200 gets forwarded to the Vagrant VM to port 8200.

After the inital provisioning is done, initialise vault:

```
$ export VAULT_CACERT=/etc/vault/keys/ca_cert.pem
$ export VAULT_ADDR='https://vault.vm:8200'
$ vault operator init

Unseal Key 1: qduQtx3VNgLN/9WP1ZRzCq1ZB709DZ3TS/D52YS6yLzr
Unseal Key 2: YSXO2hST8+FHoBrn1SgI6yn+ApriQpqiDKhrnLXH9ojP
Unseal Key 3: o+Og63B2/cJiX/8VoshTlBIb/dkCoeGrgSv2bPLQzBjE
Unseal Key 4: lfNiq0/B5V1IXyKzivjDRXqetHtcXqaHj8prF9RclL08
Unseal Key 5: DL3Xf4FSxIv6+NEYdZCZaskf0jcJ0bowe34r7Gdl7Y+9
Initial Root Token: 677b88e3-300c-3a5a-ea2f-72ba70be5516

Vault initialized with 5 keys and a key threshold of 3. Please
securely distribute the above keys. When the vault is re-sealed,
restarted, or stopped, you must provide at least 3 of these keys
to unseal it again.

Vault does not store the master key. Without at least 3 keys,
your vault will remain permanently sealed.
```

```
$ vault operator unseal
Key (will be hidden):
```

Use 3 of the unseal keys from above.

Now, ssh to the Vault VM instance and set some test data:

```
$ vault auth enable cert
$ vault write auth/cert/certs/puppetserver \
    display_name=puppet \
    policies=all_secrets \
    certificate=@/etc/vault/keys/ca_cert.pem \
    ttl=3600
$ vault policy write all_secrets - <<EOF
path "secret/*" {
    capabilities = ["read"]
}
EOF
$ vault write secret/test foo=bar
```

Now, create the `node1` instance,

```
$ vagrant up node1
```

And see the message we set earlier on:

```
Info: Using configured environment 'production'
Info: Retrieving pluginfacts
Info: Retrieving plugin
Info: Retrieving locales
Info: Loading facts
Info: Caching catalog for node1
Info: Applying configuration version '1542902874'
Notice: {"foo"=>"bar"}
Notice: /Stage[main]/Profile::Vault_message/Notify[Example]/message: changed [redacted] to [redacted]
Notice: Applied catalog in 0.18 seconds
```

You can then test that you can restrict the backend to certain policies:

```
vault write auth/cert/certs/puppetserver \
    display_name=puppet \
    policies=all_secrets \
    certificate=@/etc/vault/keys/ca_cert.pem \
    allowed_common_names="node1.vm" \
    ttl=3600
```

We can even use oid's to authenticate, which are set with the `/etc/puppetlabs/puppet/csr_attributes.yaml` file during provisoning:

```
vault write auth/cert/certs/puppetserver \
    display_name=puppet \
    policies=all_secrets \
    certificate=@/etc/vault/keys/ca_cert.pem \
    required_extensions="1.3.6.1.4.1.34380.1.1.22:vaultok" \
    ttl=3600
```

# Security

This repository is meant as a non-production sandbox setup.
It is not a guide on how to setup a secure Puppet and Vault environment.

In particular this means:

* Auto signing is enabled, every node that connects to the puppetserver is automatically signed.
* Passwords or PSKs are not randomized and easily guessable.

For a non publicly reachable playground this should be acceptable.
