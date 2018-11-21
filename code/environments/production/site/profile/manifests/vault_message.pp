# profile to deploy a puppet vault_message

class profile::vault_message {

  $d = Deferred('vault_lookup::lookup', ["secret/test", 'https://vault.vm:8200'])

  notify { "Example":
    message => $d
  }

}
