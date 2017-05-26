# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.define :'tat-dev' do |m|
    m.vm.box = "bento/centos-7.3"

    # TAT server
    m.vm.network "forwarded_port", guest: 8080, host: 8080
    # TAT webui
    m.vm.network "forwarded_port", guest: 8000, host: 8000

    # install puppet agent 1.3.4
    m.vm.provision :shell do |shell|
      shell.path = "scripts/install_puppet.sh"
    end

    # install puppet modules
    puppet_modules = ['puppetlabs-vcsrepo', 'puppet-nodejs', 'puppetlabs-stdlib']
    puppet_modules.each do |name|
      m.vm.provision :shell do |shell|
        shell.inline = "puppet module install #{name}"
      end
    end

    # run puppet apply for Puppet 4.x
    m.vm.provision :puppet do |puppet|
      puppet.environment_path = "environments"
      puppet.environment = "deploy"
      puppet.working_directory = '/tmp/vagrant-puppet/environments/deploy'
      puppet.options = '--verbose --debug'
    end
  end
end
