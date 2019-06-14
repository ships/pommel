# Increase log verbosity
log_level = "DEBUG"

# Setup data dir
data_dir = "/etc/consul.d"

bind_addr = "192.168.1.45"
client_addr = "192.168.1.45"

retry_join = ["192.168.1.40", "192.168.1.41", "192.168.1.42"]
rejoin_after_leave = true
