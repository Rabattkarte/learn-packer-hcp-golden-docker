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

data "hcp-packer-version" "golden" {
  bucket_name  = "${var.container_prefix}-base"
  channel_name = "production"
}

data "hcp-packer-artifact" "golden" {
  bucket_name         = data.hcp-packer-version.golden.bucket_name
  version_fingerprint = data.hcp-packer-version.golden.fingerprint
  platform            = "docker"
  region              = "docker"
}

source "docker" "golden" {
  image = data.hcp-packer-artifact.golden.labels["ImageDigest"]

  login          = true
  login_server   = "${var.registry_url}"
  login_username = "${var.registry_login}"
  login_password = "${var.registry_password}"

  commit = true

  changes = [
    "LABEL my_build_timestamp=${local.timestamp}",
    "LABEL my_arbitrary_label=app1"
  ]
}

build {
  name = "docker-example-app1"

  sources = [
    "source.docker.golden"
  ]

  # Add some random example file to the image
  provisioner "file" {
    source      = "./some_file.txt"
    destination = "/etc/some_file.txt"
  }

  post-processors {
    post-processor "docker-tag" {

      repository = "${var.registry_url}/${var.container_prefix}/ubuntu-basic-app1"
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
    bucket_name = "${var.container_prefix}-app1"
    description = <<EOT
This is a Docker image for App1.
    EOT

    bucket_labels = {
      "hashicorp-learn" = "${var.container_prefix}",
    }
  }
}
