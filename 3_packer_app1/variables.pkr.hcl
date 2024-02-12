variable "container_prefix" {
  type    = string
  default = "learn-packer-hcp-golden-docker"
}

variable "registry_url" {
  type    = string
  default = env("REGISTRY_URL")
}

variable "registry_login" {
  type    = string
  default = env("REGISTRY_LOGIN")
}

variable "registry_password" {
  type    = string
  default = env("REGISTRY_PASSWORD")
}

