variable "enable_detailed_monitoring" {
  type    = bool
  default = false
}
variable "instance_type" {
  description = "Enter Instance Type"
  type        = string
  default     = "t3.small"
}

variable "allow_ports" {
  description = "List of Ports to open for server"
  type        = list(any)
  default     = ["80", "443", "22"]
}

variable "environment" {
  default = "DEV"
}
variable "project_name" {
  default = "MY_TERRAFORM_PROJECT"
}
variable "owner" {
  default = "Maks Kulikov"
}
variable "name" {
  default = "MaksimKA"
}
