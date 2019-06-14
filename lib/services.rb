module Services
  def self.consul(ipaddr)
    <<~HEREDOC
      sudo mkdir -p /etc/consul.d
      sudo mv /tmp/config-consul.hcl /etc/consul.d/config.hcl

      (
      cat <<-EOF
        [Unit]
        Description=consul agent
        Requires=network-online.target
        After=network-online.target

        [Service]
        Restart=on-failure
        ExecStart=/usr/bin/consul agent -config-file /etc/consul.d/config.hcl
        ExecReload=/bin/kill -HUP $MAINPID

        [Install]
        WantedBy=multi-user.target
      EOF
      ) | sudo tee /etc/systemd/system/consul.service
      sudo systemctl enable consul.service
      sudo systemctl start consul
    HEREDOC
  end

  def self.nomad
    <<~HEREDOC
      nomad -autocomplete-install

      sudo mkdir -p /etc/nomad.d
      sudo mv /tmp/config.hcl /etc/nomad.d/config.hcl

      (
      cat <<-EOF
        [Unit]
        Description=nomad agent
        Requires=consul.service
        After=consul.service

        [Service]
        Restart=on-failure
        ExecStart=/usr/bin/nomad agent -config /etc/nomad.d/config.hcl
        ExecReload=/bin/kill -HUP $MAINPID

        [Install]
        WantedBy=multi-user.target
      EOF
      ) | sudo tee /etc/systemd/system/nomad.service
      sudo systemctl enable nomad.service
      sudo systemctl start nomad
    HEREDOC
  end
end
