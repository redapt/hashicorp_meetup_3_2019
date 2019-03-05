provider "aws" {
  region = "us-west-2"
}

provider "azurerm" {}

provider "cloudflare" {}

provider "acme" {
  server_url = "https://acme-staging-v02.api.letsencrypt.org/directory"
}

provider "docker" {
  alias = "fe"
  host = "tcp://${var.frontend_ip}:2375"

  registry_auth {
    address = "registry.hub.docker.com"
    username = "${var.docker_username}"
    password = "${var.docker_password}"
  }
}

provider "docker" {
  alias = "db"
  host = "tcp://${var.backend_ip}:2375"

  registry_auth {
    address = "registry.hub.docker.com"
    username = "${var.docker_username}"
    password = "${var.docker_password}"
  }
}