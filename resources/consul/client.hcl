# Increase log verbosity
log_level = "DEBUG"

# Setup data dir
data_dir = "/etc/consul.d"

bind_addr = "0.0.0.0"
advertise_addr = "192.168.1.45"
client_addr = "0.0.0.0"

retry_join = ["192.168.1.40"]
rejoin_after_leave = true
