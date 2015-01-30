# -*- mode: ruby -*-
# vi: set ft=ruby :

require 'json'
PMAP = ENV['TOYBOX_PORTMAP']
PMAP||= "{}"
PMAP = JSON.parse(PMAP)

# Ask the environment for some facts about whether
# the user has requested the optional provisioning
FACTER = {}
FACTER[:toybox_vagrant_invocation] = "true"
FACTER[:toybox_provision_xwin] = ENV["PROVISION_XWIN"] or ""
FACTER[:toybox_xwin_extra] = ENV["PROVISION_XWIN_EXTRA"] or ""
FACTER[:toybox_extra_packages] = ENV["PROVISION_XTRAS"] or "[]"
FACTER[:toybox_provision_neo] = ENV["PROVISION_NEO"] or ""
FACTER[:toybox_provision_mongo] = ENV["PROVISION_MONGO"] or ""
FACTER[:toybox_provision_genghis] = ENV["PROVISION_GENGHIS"] or ""
FACTER[:toybox_provision_rabbit] = ENV["PROVISION_RABBIT"] or ""

FACTER[:toybox_provision_java] = ENV["PROVISION_JAVA"] or ""
FACTER[:toybox_provision_elasticsearch] = ENV["PROVISION_ELASTICSEARCH"] or ""

VAGRANTFILE_API_VERSION = "2" # Vagrantfile API/syntax version.
DEFAULT_NAME = "toybox" # used for hostname and virtualbox nickname
Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = "trusty64"
  config.vm.hostname = DEFAULT_NAME + ".example.com"

  # The port map which creates access between guest/host:
  #   15672: this entry is for the rabbitmq WUI
  #   5555:  this entry is for the flower WUI
  #   5556:  this entry is for the genghisapp WUI
  #   9001:  this entry is for the supervisor WUI
  #   7474:  this entry is for the neo4j data/WUI
  PMAP.each do|n|
    config.vm.network "forwarded_port", guest: n[1][0], host: n[1][1]
  end

  # Provider-specific configuration so you can fine-tune various
  # backing providers for Vagrant. Options are provider-specific.
  # Use VBoxManage to customize the VM. For example to change memory:
  config.vm.provider "virtualbox" do |vb|
    vb.gui = true       # toggle on/off for headless mode
    vb.name = "zoo"
    vb.customize ["modifyvm", :id, "--vram", "16"]
    vb.customize ["modifyvm", :id, "--memory", "1024"]
    vb.customize ["setextradata", "global", "GUI/MaxGuestResolution", "any"]
    #vb.customize ["setextradata", :id, "CustomVideoMode1", "1024x768x32"]
  end

  # Enable provisioning with Puppet stand alone.  Puppet manifests
  # are contained in a directory path relative to this Vagrantfile.
  config.vm.provision :puppet, :options => "--no-report" do |puppet|
    puppet.options        = "--verbose --debug"
    puppet.manifests_path = "puppet"
    puppet.facter         = FACTER
    puppet.manifest_file  = "default.pp"
    puppet.module_path    = "puppet/modules"
  end

  # If true, then any SSH connections made will enable agent forwarding.
  # Default value: false
  # config.ssh.forward_agent = true

  # Share an additional folder to the guest VM. The first argument is
  # the path on the host to the actual folder. The second argument is
  # the path on the guest to mount the folder. And the optional third
  # argument is a set of non-required options.
  # config.vm.synced_folder "../data", "/vagrant_data"

  # Create a private network, which allows host-only access to the machine
  # using a specific IP.
  # config.vm.network "private_network", ip: "192.168.33.10"

  # Create a public network, which generally matched to bridged network.
  # Bridged networks make the machine appear as another physical device on
  # your network.
  # config.vm.network "public_network"

  # Disable automatic box update checking. If you disable this, then
  # boxes will only be checked for updates when the user runs
  # `vagrant box outdated`. This is not recommended.
  # config.vm.box_check_update = false

  # Enable provisioning with chef solo, specifying a cookbooks path, roles
  # path, and data_bags path (all relative to this Vagrantfile), and adding
  # some recipes and/or roles.
  #
  # config.vm.provision "chef_solo" do |chef|
  #   chef.cookbooks_path = "../my-recipes/cookbooks"
  #   chef.roles_path = "../my-recipes/roles"
  #   chef.data_bags_path = "../my-recipes/data_bags"
  #   chef.add_recipe "mysql"
  #   chef.add_role "web"
  #
  #   # You may also specify custom JSON attributes:
  #   chef.json = { mysql_password: "foo" }
  # end

  # Enable provisioning with chef server, specifying the chef server URL,
  # and the path to the validation key (relative to this Vagrantfile).
  #
  # The Opscode Platform uses HTTPS. Substitute your organization for
  # ORGNAME in the URL and validation key.
  #
  # If you have your own Chef Server, use the appropriate URL, which may be
  # HTTP instead of HTTPS depending on your configuration. Also change the
  # validation key to validation.pem.
  #
  # config.vm.provision "chef_client" do |chef|
  #   chef.chef_server_url = "https://api.opscode.com/organizations/ORGNAME"
  #   chef.validation_key_path = "ORGNAME-validator.pem"
  # end
  #
  # If you're using the Opscode platform, your validator client is
  # ORGNAME-validator, replacing ORGNAME with your organization name.
  #
  # If you have your own Chef Server, the default validation client name is
  # chef-validator, unless you changed the configuration.
  #
  #   chef.validation_client_name = "ORGNAME-validator"
end
