# tat-vagrant
Vagrant machine for Tat testing and development https://ovh.github.io/tat/overview/
using Chef Bento maintained CentOS 7.3 image. Other Bento box files can be located here:
https://atlas.hashicorp.com/bento/

## To build

***PREREQS***
* VMware Fusion >= 6.0
* Vagrant with Fusion Plugin

***Components Installed***
* MongoDB community 3.4
* Puppet
* Git
* NodeJS
* Tat Server
* Tat CLI
* Tat WebUI

***Getting up and running***

1. Create and start the vagrant virtual machine

   `vagrant up`

2. Connect to 'http://localhost:8000' for the WebUI and create a new account

3. Connect to vagrant VM via SSH

    `vagrant ssh`

4. Get the account registration validation URL from /var/log/tat.log

5. Go to the URL to complete registration and get the password for the new account
