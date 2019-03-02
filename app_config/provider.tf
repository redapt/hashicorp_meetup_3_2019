provider "docker" {
  alias = "fe"
  host = "tcp://${var.frontend_ip}:2376"
}

provider "docker" {
  alias = "db"
  host = "tcp://${var.backend_ip}:2376"

  registry_auth {
    address = "registry.hub.docker.com"
    username = "${var.docker_username}"
    password = "${var.docker_password}"
  }
}