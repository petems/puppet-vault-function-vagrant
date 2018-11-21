#!/bin/sh

if [ ! -f /etc/provisioned ] ; then
  # remove strange manually placed repo file
  /bin/rm -f /etc/yum.repos.d/puppetlabs*

  # install Puppet 5.x release repo
  /bin/yum -y install https://yum.puppet.com/puppet6/puppet6-release-el-7.noarch.rpm
  if [ $? -ne 0 ] ; then
    echo "Something went wrong installing the repository RPM"
    exit 1
  fi

  # install / update puppet-agent
  /bin/yum -y install puppet-agent
  if [ $? -ne 0 ] ; then
    echo "Something went wrong installing puppet-agent"
    exit 1
  fi

  echo "10.13.38.2    puppet.vm puppet" >> /etc/hosts
  echo "10.13.38.3    vault.vm vault" >> /etc/hosts

  # Update curl and install unzip
  /bin/yum -y install curl unzip

  touch /etc/provisioned

  cat << EOF > /etc/puppetlabs/puppet/csr_attributes.yaml
---
extension_requests:
  pp_securitypolicy: "vaultok"
EOF

fi

