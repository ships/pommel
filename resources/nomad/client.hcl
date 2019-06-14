# Increase log verbosity
log_level = "DEBUG"

# Setup data dir
data_dir = "/etc/nomad.d"

bind_addr = "192.168.1.45"

client {
  enabled = true
  servers = [
  "192.168.1.40:4647",
  "192.168.1.41:4647",
  "192.168.1.42:4647",
  ]
}


