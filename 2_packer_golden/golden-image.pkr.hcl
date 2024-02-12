packer {
  required_plugins {
    docker = {
      source  = "github.com/hashicorp/docker"
      version = "~> 1"
    }
  }
}

locals {
  timestamp = regex_replace(timestamp(), "[- TZ:]", "")
}

source "docker" "ubuntu" {
  image  = "ubuntu:jammy"
  commit = true

  changes = [
    "LABEL my_build_timestamp=${local.timestamp}",
    "LABEL my_arbitrary_label=${var.container_prefix}"
  ]
}

build {
  name = "docker-example-golden"

  sources = [
    "source.docker.ubuntu"
  ]

  provisioner "shell" {
    environment_vars = [
      "FOO=${var.message}",
    ]
    inline = [
      "echo Adding file to Docker Container",
      "echo \"FOO is $FOO\" > /etc/my_example.conf"
    ]
  }

  post-processors {
    post-processor "docker-tag" {
      repository = "${var.registry_url}/${var.container_prefix}/ubuntu-basic-gold"
      tags       = ["${local.timestamp}", "latest"]
    }

    post-processor "docker-push" {
      login          = true
      login_server   = "${var.registry_url}"
      login_username = "${var.registry_login}"
      login_password = "${var.registry_password}"
    }
  }

  # HCP Packer settings
  hcp_packer_registry {
    bucket_name = "${var.container_prefix}-base"
    description = <<EOT
This is a golden base Docker image.
    EOT

    bucket_labels = {
      "hashicorp-learn" = "${var.container_prefix}",
    }
  }
}
