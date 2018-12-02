VAGRANTFILE_API_VERSION = "2"

vagrant_root = File.dirname(__FILE__)
vagrant_home = "#{Dir.home}/.vagrant.d"
amipo1_extra_disk_filepath = "#{vagrant_home}/amipo1_extra_disk.vdi"

ssh_private_key_path = "#{vagrant_root}/.amipoLocal/vagrant_ssh_key"

host_ip = "192.168.56.1"
controller_ip = "192.168.56.101"
amipo1_ip = "192.168.56.111"

proxy_http_url = "http://#{host_ip}:3128/"
proxy_https_url = proxy_http_url

## Execute vbox storage cleaning script
#system("
#    if [ \( #{ARGV[0]} = 'up' \) -a \( #{ARGV[1]} = '' -o #{ARGV[1]} = 'amipo1' \) ]; then
#        echo 'Execute vbox storages cleaning script ...'
#        #{vagrant_root}/scripts/clean_vbox_storages.sh '#{amipo1_extra_disk_filepath}'
#    fi
#")

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  # Use the same key for each machine
  config.ssh.insert_key = false

  # Enable ssh agent forwarding
  config.ssh.forward_agent = true

  #config.vm.box = "ubuntu/xenial64"
  #config.vm.box = "debian/contrib-stretch64"
  config.vm.box = "bento/debian-9.5"
  #config.vm.box = "hashicorp/precise64"


  # Enable vagrant plugin landrush to help vagrant boxes dns to resolve box names
  if Vagrant.has_plugin?("landrush")
    config.landrush.enabled = true
    config.landrush.tld = "dev"
    config.landrush.guest_redirect_dns = true
    config.landrush.host_redirect_dns = false #Disable this because it don't works on all linux
  end

  # Configure hostupdater plugin to not remove hosts on destruction from hosts file
  if Vagrant.has_plugin?("vagrant-hostsupdater")
    config.hostsupdater.remove_on_suspend = false
  end

  #config.vm.synced_folder ".", "/vagrant", type: "rsync"

  # Config proxy if a proxy is used
  if Vagrant.has_plugin?("vagrant-proxyconf")
    config.proxy.http     = proxy_http_url
    config.proxy.https    = proxy_https_url
    config.proxy.no_proxy = "localhost,127.0.0.1,.dev,.lxc"
  end

  config.vm.provider "virtualbox" do |vb|
    # Use the NAT host DNS resolver to speed up internet connections
    vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
    vb.customize ["modifyvm", :id, "--natdnsproxy1", "on"]
    # Use virtio to speedup network
    vb.customize ["modifyvm", :id, "--nictype1", "virtio"]
    # Reduce Ubuntu boot time
    vb.customize ["modifyvm", :id, "--uartmode1", "disconnected" ]

    # Default vm config
    vb.customize ["modifyvm", :id, "--memory", 512]
  end

  # VM Controller.
  config.vm.define "controller" do |machine|
    machine.vm.hostname = "controller.dev"

    # Define a private IP
    machine.vm.network :private_network, ip: "#{controller_ip}"

    # VM aliases to add in /etc/hosts file
    if Vagrant.has_plugin?("vagrant-hostsupdater")
      machine.hostsupdater.aliases = ["controller.dev"]
    end

    # Mount vagrant dir to vagrant home
    machine.vm.synced_folder "#{vagrant_root}/ansible", "/home/vagrant/ansible"

    # Copy insecure_private_key in controller to allow provide large ssh access from controller on all Vagrant boxes. Usefull for debugging.
    machine.vm.synced_folder "#{vagrant_home}", "/home/vagrant/.vagrantSsh/", type: "rsync", rsync__args: [--include="#{vagrant_home}/insecure_private_key"]

    machine.vm.provider :virtualbox do |vb|
      vb.customize ["modifyvm", :id, "--name", "controller"]
      vb.customize ["modifyvm", :id, "--memory", 256]
    end

    # Run Ansible from the Vagrant VM
    machine.vm.provision "ansible_local" do |ansible|
      ansible.install_mode = "pip"
      ansible.verbose = true
      ansible.compatibility_mode = "2.0"
      ansible.provisioning_path = "/home/vagrant/ansible"
      ansible.config_file = "ansible.cfg"
      ansible.inventory_path = "development_inventory"
      ansible.playbook = "/home/vagrant/ansible/provision_controller.yml"
      ansible.limit = "all"
    end
  end

  # VM Amipo1
  config.vm.define "amipo1" do |machine|
    machine.vm.hostname = "amipo1.dev"
   
    machine.trigger.before :up do |trigger|
      trigger.run = {inline: "#{vagrant_root}/scripts/clean_vbox_storages.sh '#{amipo1_extra_disk_filepath}'"}
    end
 
#    # Ensure machine network is up
#    machine.trigger.before :provision do |trigger|
#      trigger.run = {inline: "#{vagrant_root}/scripts/waitNetworkUp.sh 'amipo1.dev'"}
#    end
 
    # Define a private IP
    machine.vm.network :private_network, ip: "#{amipo1_ip}"
    
    # Define alaises
    config.hostsupdater.aliases = ["amipo.dev", "www.amipo.dev", "test.amipo.dev"]
    config.landrush.host "amipo.dev", "#{amipo1_ip}"
    config.landrush.host "www.amipo.dev", "#{amipo1_ip}"
    config.landrush.host "test.amipo.dev", "#{amipo1_ip}"
    config.landrush.host "amipo1.dev", "#{amipo1_ip}"

    machine.vm.provider :virtualbox do |vb|
      # Change vm ID, needed for storage
      vb.customize ["modifyvm", :id, "--name", "amipo1"]
    end

    # Ensure lvm2 is present in the box
    machine.vm.provision "shell", inline: "sudo apt-get --assume-yes install lvm2"

    # Add an extra LVM storage to persist beyond the VM destruction.
    machine.persistent_storage.enabled = false
    machine.persistent_storage.partition = true
    machine.persistent_storage.location = amipo1_extra_disk_filepath
    machine.persistent_storage.size = 5000
    machine.persistent_storage.diskdevice = '/dev/sdc'
    machine.persistent_storage.mountname = 'extra_lv'
    machine.persistent_storage.filesystem = 'ext4'
    machine.persistent_storage.mountpoint = '/mnt/extra'
    machine.persistent_storage.volgroupname = 'amipo_vg'

    # Run script to increase swap memory
    #machine.vm.provision "shell", path: "increase_swap.sh"

    # Bootstrap ansible in box
    machine.vm.provision "shell", path: "#{vagrant_root}/scripts/bootstrap_ansible_with_apt.sh"

    # Provision the VM with the ansible installed on controller
    machine.vm.provision "ansible" do |ansible|
      ansible.playbook_command = "#{vagrant_root}/scripts/ansible-playbook"
      ansible.playbook = "#{vagrant_root}/ansible/provision_amipo_dev.yml"
      ansible.verbose = true
      ansible.limit = "all"
    end

  end


end
