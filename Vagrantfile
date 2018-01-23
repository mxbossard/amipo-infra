VAGRANTFILE_API_VERSION = "2"

amipo_lxc_disk_file = "amipo1_disk1.vdi"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  # Use the same key for each machine
  config.ssh.insert_key = false
  config.vm.box = "ubuntu/xenial64"

  # VM of an AMIPO host managing LXC containers
  config.vm.define "amipo1.vagrant" do |machine|
    #machine.vm.box = "debian/stretch64"
    machine.vm.hostname = "amipo1"
    
    # Forward port if no private IP
    #machine.vm.network "forwarded_port", guest: 80, host: 8080
    #machine.vm.network "forwarded_port", guest: 443, host: 8443

    # Define a private IP
    machine.vm.network :private_network, ip: "192.168.56.111"

    machine.vm.provider :virtualbox do |vb|
      vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
      vb.customize ["modifyvm", :id, "--memory", 512]
      #vb.customize ["modifyvm", :id, "--name", "amipo1.vagrant"]
      vb.customize ["modifyvm", :id, "--name", "amipo1"]

      # Validate this should be run it once
      if ARGV[0] == "up" && ! File.exist?(amipo_lxc_disk_file)
        vb.customize [
          'createhd',
          '--filename', amipo_lxc_disk_file,
          '--format', 'VDI',
          # 2GB
          '--size', 2 * 1024 * 1024
        ]

        vb.customize [
          'storageattach', :id,
          '--storagectl', 'SATAController',
          '--port', 1, 
          '--device', 0,
          '--type', 'hdd', '--medium',
          amipo_lxc_disk_file
        ]
      end


    end


    if ARGV[0] == "up" && ! File.exist?(amipo_lxc_disk_file)
      # Run script to map new disk
      machine.vm.provision "shell", path: "scripts/bootstrap_lvm.sh"
      # Run script to increase swap memory
      #machine.vm.provision "shell", path: "increase_swap.sh"
    end

    # Provision with ansible
    #machine.vm.provision :ansible do |ansible|
    #  ansible.playbook = "playbooks/setup_amipo_host.yml"
    #  ansible.groups = {
    #    "lxc_host" => ["amipo1.vagrant"]
    #  }
    #end

  end

  # VM of an AMIPO controller managing deployment.
  config.vm.define "controller.vagrant" do |machine|
    #machine.vm.box = "ubuntu/xenial64"
    machine.vm.hostname = "controller"

    # Define a private IP
    machine.vm.network :private_network, ip: "192.168.56.101"

    # Run Ansible from the Vagrant VM
    machine.vm.provision "ansible_local" do |ansible|
      ansible.playbook = "playbooks/setup_amipo_host.yml"
      ansible.install_mode = "pip"
      ansible.groups = {
        "lxc_host" => ["amipo1.vagrant"]
      }
    end
  end

end
