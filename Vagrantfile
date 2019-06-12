# -*- mode: ruby -*-
# vi: set ft=ruby :

def script_for(ipaddr) {
  %Q^echo "Installing Docker..."
sudo apt-get update
sudo apt-get remove docker docker-engine docker.io
sudo apt-get install apt-transport-https ca-certificates curl software-properties-common -y
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg |  sudo apt-key add -
sudo apt-key fingerprint 0EBFCD88
sudo add-apt-repository \
      "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
      $(lsb_release -cs) \
      stable"
sudo apt-get update
sudo apt-get install -y docker-ce
# Restart docker to make sure we get the latest version of the daemon if there is an upgrade
sudo service docker restart
# Make sure we can actually use docker as the vagrant user
sudo usermod -aG docker vagrant
sudo docker --version

# Packages required for nomad & consul
sudo apt-get install unzip curl vim -y

echo "Installing Nomad..."
NOMAD_VERSION=0.9.1
cd /tmp/
curl -sSL https://releases.hashicorp.com/nomad/${NOMAD_VERSION}/nomad_${NOMAD_VERSION}_linux_amd64.zip -o nomad.zip
unzip nomad.zip
sudo install nomad /usr/bin/nomad
sudo mkdir -p /etc/nomad.d
sudo chmod a+w /etc/nomad.d


echo "Installing Consul..."
CONSUL_VERSION=1.4.0
curl -sSL https://releases.hashicorp.com/consul/${CONSUL_VERSION}/consul_${CONSUL_VERSION}_linux_amd64.zip > consul.zip
unzip /tmp/consul.zip
sudo install consul /usr/bin/consul
(
cat <<-EOF
  [Unit]
  Description=consul agent
  Requires=network-online.target
  After=network-online.target

  [Service]
  Restart=on-failure
  ExecStart=/usr/bin/consul agent -dev #{ipaddr}
  ExecReload=/bin/kill -HUP $MAINPID

  [Install]
  WantedBy=multi-user.target
EOF
) | sudo tee /etc/systemd/system/consul.service
sudo systemctl enable consul.service
sudo systemctl start consul

for bin in cfssl cfssl-certinfo cfssljson
do
  echo "Installing $bin..."
  curl -sSL https://pkg.cfssl.org/R1.2/${bin}_linux-amd64 > /tmp/${bin}
  sudo install /tmp/${bin} /usr/local/bin/${bin}
done

nomad -autocomplete-install

sudo mkdir -p /opt/nomad/
sudo mv /tmp/config.hcl /opt/nomad

(
cat <<-EOF
  [Unit]
  Description=nomad agent
  Requires=consul.service
  After=consul.service

  [Service]
  Restart=on-failure
  ExecStart=/usr/bin/nomad agent -config /opt/nomad/config.hcl
  ExecReload=/bin/kill -HUP $MAINPID

  [Install]
  WantedBy=multi-user.target
EOF
) | sudo tee /etc/systemd/system/nomad.service
sudo systemctl enable nomad.service
sudo systemctl start nomad ^
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
      server.vm.provision "file", source: "./resources/server.hcl.#{i}", destination: "/tmp/config.hcl"
      server.vm.provision "shell", inline: script_for(myip), privileged: false
      server.vm.provider "virtualbox" do |vb|
        vb.memory = "256"
      end
    end
  end

  (0...num_workers).each do |j|
    config.vm.define "w#{j}" do |worker|
      worker.vm.hostname = "nomad-w#{j}"
      myip = "192.168.1.5#{i}"

      # Expose the nomad api and ui to the host
      worker.vm.network "public_network", bridge: "eno1", ip: myip
      worker.vm.provision "file", source: "./resources/client.hcl", destination: "/tmp/config.hcl"
      worker.vm.provision "shell", inline: script_for(myip), privileged: false
      worker.vm.provider "virtualbox" do |vb|
        vb.memory = "4096"
      end
    end
  end

end
