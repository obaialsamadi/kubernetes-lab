# -*- mode: ruby -*-
# vi: set ft=ruby :

# [NOTE] => disabled experimental flags
# default_experimental = ENV['VAGRANT_EXPERIMENTAL'] || 'disks'
# ENV['VAGRANT_EXPERIMENTAL'] = default_experimental
default_provider = ENV['VAGRANT_DEFAULT_PROVIDER'] || 'virtualbox'
ENV['VAGRANT_DEFAULT_PROVIDER'] = default_provider
NAME=ENV["VAGRANT_MACHINE_NAME"] || File.basename(Dir.pwd)
MEMORY_LIMIT=ENV["MEMORY_LIMIT"] || 8192
CORE_LIMIT=ENV["CORE_LIMIT"] || 4
$cleanup_script = <<-SCRIPT
apt-get autoremove -yqq --purge > /dev/null 2>&1
apt-get autoclean -yqq > /dev/null 2>&1
apt-get clean -qq > /dev/null 2>&1
rm -rf /var/lib/apt/lists/*
SCRIPT
Vagrant.configure("2") do |config|
  config.vm.define "vagrant-#{NAME}"
  config.vm.hostname = "vagrant-#{NAME}"
  config.vm.box = "generic/debian10"
  # => forward lxd port
  config.vm.network "forwarded_port", guest: 8443, host: 8443,auto_correct: true
  # => forward nomad server port
  config.vm.network "forwarded_port", guest: 4646,host: 4646,auto_correct: true
  # => forward port 8080 in case needed 
  config.vm.network "forwarded_port", guest: 8080, host: 8080,auto_correct: true
  config.vm.provider "virtualbox" do |vb, override|
    override.vagrant.plugins=["vagrant-share","vagrant-vbguest"]
    vb.memory = "#{MEMORY_LIMIT}"
    vb.cpus   = "#{CORE_LIMIT}"
    # => enable nested virtualization
    vb.customize ["modifyvm", :id, "--nested-hw-virt", "on"]
    override.vm.synced_folder ".", "/vagrant", owner: "vagrant",group: "vagrant", type: "virtualbox"
  end
  # [NOTE] => libvirt has not been tested
  config.vm.provider "libvirt" do |libvirt,override|
    ENV['CONFIGURE_ARGS']="with-libvirt-include=/usr/include/libvirt with-libvirt-lib=/usr/lib" 
    override.vagrant.plugins=["pkg-config","vagrant-mutate","vagrant-share","vagrant-libvirt"]
    libvirt.memory = "#{MEMORY_LIMIT}"
		libvirt.cpus = "#{CORE_LIMIT}"
		libvirt.random :model => 'random'
		libvirt.cpu_mode = "host-model"
    libvirt.nested = true
  end
  config.vm.provider :openstack do |os,override|
  	# [NOTE] => Read in the bash environment, after an optional command.
  	# Returns Array of key/value pairs.
  	def bash_env(cmd=nil)
  	  env = `#{cmd + ';' if cmd} printenv`
  	  env.split(/\n/).map {|l| l.split(/=/)}
  	end
  	# [NOTE] => Source a given file, and compare environment before and after.
  	# Returns Hash of any keys that have changed.
  	def bash_source(file)
  	  Hash[ bash_env(". #{File.realpath file}") - bash_env() ]
  	end
  	# [NOTE] => Find variables changed as a result of sourcing the given file, 
  	# and update in ENV.
  	def source_env_from(path)
  	  Dir.glob("#{path}").each do |file|
  	    bash_source(file).each {|k,v| ENV[k] = v}
  	  end
  	end
    override.vagrant.plugins=["vagrant-share","vagrant-openstack-provider","vagrant-rsync-back"]
    # make sure openstac rc file is sourced
    source_env_from("#{ENV['HOME']}/*-openrc.sh")
    # [NOTE] => disabled logs
    #default_openstack_log         = ENV['VAGRANT_OPENSTACK_LOG'] || 'info'
    #ENV['VAGRANT_OPENSTACK_LOG']  = default_openstack_log
    os.openstack_auth_url         = "#{ENV['OS_AUTH_URL']}/v3/auth/tokens"
    os.identity_api_version       = ENV["OS_IDENTITY_API_VERSION"]
    os.domain_name                = ENV['OS_USER_DOMAIN_NAME']
    os.username                   = ENV['OS_USERNAME']
    os.password                   = ENV['OS_PASSWORD']
    os.project_name               = ENV['OS_PROJECT_NAME']
    os.region                     = ENV['OS_REGION_NAME']
    os.flavor                     = ENV["OS_FLAVOR"] || 'r1-4'
    os.security_groups            = ["default","ssh"]
    os.image                      = 'vagrant-debian-buster'
    override.ssh.username         = 'vagrant'
    override.ssh.password         = 'vagrant'
    override.ssh.insert_key       = true
    override.vm.synced_folder ".", "/vagrant", type: 'rsync',
      rsync__args: ["--verbose", "--archive", "-z"],
      owner: "vagrant",group: "vagrant",
      sync__exclude: [
        '.git',
        '.vagrant',
      ]
    override.vm.provision "shell",privileged:true,name:"remove-debian", inline: <<-SCRIPT
    sudo getent passwd "debian" > /dev/null && sudo killall -u 'debian' > /dev/null 2>&1 || true
    sudo getent passwd "debian" > /dev/null && sudo userdel --remove --force 'debian' > /dev/null 2>&1 || true
    sudo rm -rf /home/debian
    SCRIPT
  end
  config.vm.provision "file",source: "contrib/vagrant/bin", destination: "/tmp/bin"
  config.vm.provision "shell",privileged:true,name:"cleanup", inline: $cleanup_script
  config.vm.provision "shell",privileged:false,name:"init", path: "contrib/vagrant/provision/init.sh"
  config.vm.provision "shell",privileged:true,name:"node", path: "contrib/vagrant/provision/node.sh"
  config.vm.provision "shell",privileged:false,name:"python", path: "contrib/vagrant/provision/python.sh"
  config.vm.provision "shell",privileged:false,name:"ansible", path: "contrib/vagrant/provision/ansible.sh"
  config.vm.provision "shell",privileged:false,name:"goenv", path: "contrib/vagrant/provision/goenv.sh"
  config.vm.provision "shell",privileged:false,name:"levant", path: "contrib/vagrant/provision/levant.sh"
  config.vm.provision "shell",privileged:false,name:"rbenv", path: "contrib/vagrant/provision/rbenv.sh"
  config.vm.provision "shell",privileged:false,name:"spacevim", path: "contrib/vagrant/provision/spacevim.sh"
  config.vm.provision "shell",privileged:true,name:"hashicorp", path: "contrib/vagrant/provision/hashicorp.sh"
  config.vm.provision "shell",privileged:true,name:"ripgrep", path: "contrib/vagrant/provision/ripgrep.sh"
  config.vm.provision "shell",privileged:true,name:"docker", path: "contrib/vagrant/provision/docker.sh"
  config.vm.provision "shell",privileged:true,name:"lxd", path: "contrib/vagrant/provision/lxd.sh"
  config.trigger.after [:provision] do |t|
    t.info = "cleaning up after provisioning"
    t.run_remote = {inline: $cleanup_script }
  end
end
