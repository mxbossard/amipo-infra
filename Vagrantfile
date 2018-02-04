VAGRANTFILE_API_VERSION = "2"

amipo_lxc_disk_file = "#{Dir.home}/.vagrant.d/amipo1_disk_lxc.vdi"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  # Use the same key for each machine
  config.ssh.insert_key = false
  #config.ssh.private_key_path = "ansible/.ssh/vagrant_ssh_key"

  config.vm.box = "ubuntu/xenial64"
  #config.vm.box = "debian/stretch64"

  # Enable vagrant plugin landrush to help vagrant boxes dns to resolve box names
  config.landrush.enabled = true
  config.landrush.tld = "dev";
  config.landrush.guest_redirect_dns = true

  config.vm.synced_folder ".", "/vagrant", type: "rsync"

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


  # VM of an AMIPO host managing LXC containers
  config.vm.define "amipo1" do |machine|
    machine.vm.hostname = "amipo1.dev"
    
    # Define a private IP
    machine.vm.network :private_network, ip: "192.168.56.111"

    machine.vm.provider :virtualbox do |vb|
      # Change vm ID, needed for storage
      vb.customize ["modifyvm", :id, "--name", "amipo1"]
    end

    # Ensure lvm2 is present in the box
    machine.vm.provision "shell", inline: "sudo apt-get --assume-yes install lvm2"

    # Add an LVM storage for LXC
    machine.persistent_storage.enabled = true
    machine.persistent_storage.partition = true
    machine.persistent_storage.location = amipo_lxc_disk_file
    machine.persistent_storage.size = 5000
    machine.persistent_storage.diskdevice = '/dev/sdc'
    machine.persistent_storage.mountname = 'lxc-lv'
    machine.persistent_storage.filesystem = 'ext4'
    machine.persistent_storage.mountpoint = '/mnt/lxc'
    machine.persistent_storage.volgroupname = 'lxc-vg'

    # Run script to increase swap memory
    #machine.vm.provision "shell", path: "increase_swap.sh"

    # Install python 2.7
    machine.vm.provision "shell", inline: "sudo apt install -y python2.7; test -f /usr/bin/python || ln -s /usr/bin/python2.7 /usr/bin/python"

  end

  # VM of an AMIPO controller managing deployment.
  config.vm.define "controller" do |machine|
    machine.vm.hostname = "controller.dev"

    # Define a private IP
    machine.vm.network :private_network, ip: "192.168.56.101"

    # Mount vagrant dir to vagrant home
    machine.vm.synced_folder "./ansible", "/home/vagrant/ansible"

    # Copy insecure_private_key in controller guest for ansible usage
    machine.vm.synced_folder "#{Dir.home}/.vagrant.d", "/home/vagrant/.vagrantSsh/", type: "rsync", rsync__args: [--include="#{Dir.home}/.vagrant.d/insecure_private_key"]

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
      ansible.inventory_path = "inventory"
      ansible.playbook = "playbooks/provision_amipo_test.yml"
      ansible.limit = "all"
    end
  end

end
