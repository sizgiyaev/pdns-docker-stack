# -*- mode: ruby -*-
# vi: set ft=ruby :

$script = <<EOS

# Install common-packages
sudo apt-get update
sudo apt-get install apt-transport-https \
                      ca-certificates \
                      curl \
                      gnupg2 \
                      python-pip \
                      software-properties-common -y
sudo pip install --upgrade pip
sudo pip install docker-compose


# Install Docker CE
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add -
sudo apt-key fingerprint 0EBFCD88
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable"
sudo apt-get update
sudo apt-get install docker-ce -y

# Build and run PDNS dockers
#docker 

EOS

Vagrant.configure("2") do |config|

  config.vm.define "virtualbox" do |virtualbox|
    virtualbox.vm.hostname = "pdns-stack-test01"
    virtualbox.vm.box = "debian/contrib-jessie64"
    config.vm.box_version = "8.7.0"
    config.vm.network "private_network", type: "dhcp", virtualbox__intnet: true

    config.vm.provider :virtualbox do |v|
      v.gui = false
      v.memory = 2048
      v.cpus = 2
    end
    
    config.vm.synced_folder "docker/", "/docker"
    
    config.vm.provision "shell", inline: $script

  end

end