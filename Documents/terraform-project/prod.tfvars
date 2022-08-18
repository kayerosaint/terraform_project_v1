region                     = "ca-central-1"
instance_type              = "t2.small"
enable_detailed_monitoring = true
allow_ports                = ["80", "443"]
common_tags = {
  Owner       = "Daniel Haritonov"
  Project     = "Version 2"
  Environment = "prod"
}
