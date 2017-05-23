#!/bin/bash
if [ ! -f /opt/puppetlabs/bin/puppet ]; then
  echo 'installing puppetlabs yum repository and puppet-agent-1.3.4 since /opt/puppetlabs/bin/puppet does not exist'
  rpm -Uvh https://yum.puppetlabs.com/puppetlabs-release-pc1-el-7.noarch.rpm
  yum install puppet-agent-1.3.4 -y
else
  echo 'puppet-agent-1.3.4 already installed.'
fi
