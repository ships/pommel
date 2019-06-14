module Packages
  def self.docker
    <<~HEREDOC
      echo "Installing Docker..."
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
    HEREDOC
  end

  def self.apt
    <<~HEREDOC
      # Packages required for nomad & consul
      sudo apt-get install unzip curl vim -y
    HEREDOC
  end

  def self.cfssl
    <<~HEREDOC
      for bin in cfssl cfssl-certinfo cfssljson
      do
        echo "Installing $bin..."
        curl -sSL https://pkg.cfssl.org/R1.2/${bin}_linux-amd64 > /tmp/${bin}
        sudo install /tmp/${bin} /usr/local/bin/${bin}
      done
    HEREDOC
  end

  def self.nomad(version)
    <<~HEREDOC
      echo "Installing Nomad..."
      NOMAD_VERSION=#{version}
      cd /tmp/
      curl -sSL https://releases.hashicorp.com/nomad/${NOMAD_VERSION}/nomad_${NOMAD_VERSION}_linux_amd64.zip -o nomad.zip
      unzip nomad.zip
      sudo install nomad /usr/bin/nomad
      sudo mkdir -p /etc/nomad.d
      sudo chmod a+w /etc/nomad.d
    HEREDOC
  end

  def self.consul(version)
    <<~HEREDOC
      echo "Installing Consul..."
      CONSUL_VERSION=#{version}
      curl -sSL https://releases.hashicorp.com/consul/${CONSUL_VERSION}/consul_${CONSUL_VERSION}_linux_amd64.zip > consul.zip
      unzip /tmp/consul.zip
      sudo install consul /usr/bin/consul
    HEREDOC
  end
end
