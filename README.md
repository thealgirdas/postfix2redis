postfix2redis
=============

Chef Cookbook I did for myself as a learning exercise using Vagrant, Chef and Redis.

* Currently made for **CentOS 6.5 only**.
* Modifies postfix configs and hooks as filter for incoming mail with postfix2redis.sh.
* Copies a postfix2redis.sh script, which sends the data it receives to Redis.
* And installs Redis server from Remi's repository.

Requirements
============

Depends on yum package.

> knife cookbook site install yum

Vagrant
=======

As I'm using this on my laptop in solo mode, my Vagrantfile is:

```
# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = "centos65"
  config.vm.box_url = "http://opscode-vm-bento.s3.amazonaws.com/vagrant/virtualbox/opscode_centos-6.5_chef-provisionerless.box"
  config.vm.hostname = "centos"

  # Disable automatic box update checking. If you disable this, then
  # boxes will only be checked for updates when the user runs
  # `vagrant box outdated`. This is not recommended.
  # config.vm.box_check_update = false

  #config.vm.network "forwarded_port", guest: 80, host: 8080
  config.vm.network "forwarded_port", guest: 6379 , host: 6379

  # config.vm.synced_folder "../data", "/vagrant_data"
  # config.vm.synced_folder './code', '/home/vagrant/code', nfs: true

  config.vm.provider "virtualbox" do |vb|
    # Don't boot with headless mode
    vb.gui = true
    # Use VBoxManage to customize the VM. For example to change memory:
    # vb.customize ["modifyvm", :id, "--memory", "1024"]
  end

  # To install it, type: vagrant plugin install vagrant-omnibus
  config.omnibus.chef_version = :latest

  # Enable provisioning with chef solo, specifying a cookbooks path, roles
  # path, and data_bags path (all relative to this Vagrantfile), and adding
  # some recipes and/or roles.
  config.vm.provision "chef_solo" do |chef|
    chef.cookbooks_path = [ "cookbooks", "site-cookbooks"]

    #chef.add_recipe "redisio"
    #chef.add_recipe "redisio::enable"
    chef.add_recipe "yum"
    chef.add_recipe "postfix2redis"

    #chef.add_role "web"
  
    # You may also specify custom JSON attributes:
    #chef.json = { script : "/etc/postfix/postfix2redis.sh" }

    # http://stackoverflow.com/questions/22991561/chef-solo-ssl-warning-when-provisioning
    chef.custom_config_path = "Vagrantfile.chef"
  end

end
```

And Vagrant.chef:

> Chef::Config.ssl_verify_mode = :verify_peer


Fire up your VM

> vagrant up


Recipes
=======

There are a few recipes for this cookbook. The default one just includes all of them.

* `postfix2redis::default` - The default recipe which does all the stuff.
* `postfix2redis::postfix` - Only configures Postfix. Skips Redis setup.
* `postfix2redis::redis` - Only sets up Redis. Skips Postfix configuration.
* `postfix2redis::mailx` - Only install mailx package. For use of 'mail' command.


test-kitchen
============

Using BATS for test-kitchen. My `.kitchen.yml` looks like:

```
---
driver_plugin: vagrant
driver_config:
  require_chef_omnibus: true

provisioner: chef_zero

platforms:
  - name: centos-6.5

suites:
  - name: postfix2redis_suite
    run_list:
      - recipe[postfix2redis::default]
      # - recipe[postfix2redis::postfix]
      # - recipe[postfix2redis::mailx]
      # - recipe[postfix2redis::redis]
    attributes: {}

```
