variable "prefix" {
  description = "This prefix will be included in the name of most resources."
  default = "learn-packer-hcp-golden-docker"
}

variable "location" {
  description = "The region where the virtual network is created."
  default     = "centralus"
}
