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

system("
    if [ #{ARGV[0]} = 'up' ]; then
        echo 'Execute vbox storages cleaning script ...'
        #{vagrant_root}/scripts/clean_vbox_storages.sh '#{amipo1_extra_disk_filepath}'
    fi
")

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  # Use the same key for each machine
  config.ssh.insert_key = false
  #config.ssh.private_key_path = ssh_private_key_path

  # Enable ssh agent forwarding
  config.ssh.forward_agent = true

  #config.vm.box = "ubuntu/xenial64"
  config.vm.box = "debian/contrib-stretch64"

  # Enable vagrant plugin landrush to help vagrant boxes dns to resolve box names
  config.landrush.enabled = true
  config.landrush.tld = "dev";
  config.landrush.guest_redirect_dns = true

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

    # Mount vagrant dir to vagrant home
    machine.vm.synced_folder "#{vagrant_root}/ansible", "/home/vagrant/ansible"

    # Copy insecure_private_key in controller to allow provide large ssh access from controller on all Vagrant boxes. Usefull for debugging.
    machine.vm.synced_folder "#{vagrant_home}", "/home/vagrant/.vagrantSsh/", type: "rsync", rsync__args: [--include="#{vagrant_home}/insecure_private_key"]

    machine.vm.provider :virtualbox do |vb|
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
    
    # Define a private IP
    machine.vm.network :private_network, ip: "#{amipo1_ip}"

    machine.vm.provider :virtualbox do |vb|
      # Change vm ID, needed for storage
      vb.customize ["modifyvm", :id, "--name", "amipo1"]
    end

    # Ensure lvm2 is present in the box
    machine.vm.provision "shell", inline: "sudo apt-get --assume-yes install lvm2"

    # Add an LVM storage for LXC
    machine.persistent_storage.enabled = true
    machine.persistent_storage.partition = true
    machine.persistent_storage.location = amipo1_extra_disk_filepath
    machine.persistent_storage.size = 5000
    machine.persistent_storage.diskdevice = '/dev/sdc'
    machine.persistent_storage.mountname = 'lxc_lv'
    machine.persistent_storage.filesystem = 'ext4'
    machine.persistent_storage.mountpoint = '/mnt/lxc'
    machine.persistent_storage.volgroupname = 'amipo_vg'

    # Run script to increase swap memory
    #machine.vm.provision "shell", path: "increase_swap.sh"

    # Bootstrap ansible in box
    machine.vm.provision "shell", path: "#{vagrant_root}/scripts/bootstrap_ansible.sh"
    #machine.vm.provision "shell", inline: "sudo apt install -y python2.7; test -f /usr/bin/python || ln -s /usr/bin/python2.7 /usr/bin/python"

    machine.vm.provision "ansible" do |ansible|
      ansible.playbook_command = "#{vagrant_root}/scripts/ansible-playbook"
      ansible.playbook = "#{vagrant_root}/ansible/provision_amipo_test.yml"
      ansible.verbose = true
      ansible.limit = "all"
    end

  end


end
