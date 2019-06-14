# -*- mode: ruby -*-
# vi: set ft=ruby :

require_relative 'lib/include.rb'

def script_for(ipaddr)
  [ Packages.apt,
    Packages.cfssl,
    Packages.docker,
    Packages.nomad(NOMAD_VERSION),
    Packages.consul(CONSUL_VERSION),

    Services.consul(ipaddr),
    Services.nomad,
  ].join("\n")
end

num_servers=3
num_workers=1

Vagrant.configure(2) do |config|
  config.vm.box = "bento/ubuntu-18.04" # 18.04 LTS
  (0...num_servers).each do |i|
    config.vm.define "s#{i}" do |server|
      server.vm.hostname = "nomad-s#{i}"
      myip = "192.168.1.4#{i}"

      # Expose the nomad api and ui to the host
      server.vm.network "public_network", bridge: "eno1", ip: myip
      server.vm.provision "file", source: "./resources/nomad/server.hcl.#{i}", destination: "/tmp/config.hcl"
      server.vm.provision "file", source: "./resources/consul/server.hcl.#{i}", destination: "/tmp/config-consul.hcl"
      server.vm.provision "shell", inline: script_for(myip), privileged: false
      server.vm.provider "virtualbox" do |vb|
        vb.linked_clone = true
        vb.memory = "512"
      end
    end
  end

  (0...num_workers).each do |j|
    config.vm.define "w#{j}" do |worker|
      worker.vm.hostname = "nomad-w#{j}"
      num = 45 + j
      myip = "192.168.1.#{num}"

      # Expose the nomad api and ui to the host
      worker.vm.network "public_network", bridge: "eno1", ip: myip
      worker.vm.provision "file", source: "./resources/nomad/client.hcl", destination: "/tmp/config.hcl"
      worker.vm.provision "file", source: "./resources/consul/client.hcl", destination: "/tmp/config-consul.hcl"
      worker.vm.provision "shell", inline: script_for(myip), privileged: false
      worker.vm.provider "virtualbox" do |vb|
        vb.linked_clone = true
        vb.memory = "4096"
      end
    end
  end

end
