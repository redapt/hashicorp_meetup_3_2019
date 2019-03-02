provider "docker" {
  alias = "fe"
  host = "tcp://${var.frontend_ip}:2376"
}

provider "docker" {
  alias = "db"
  host = "tcp://${var.backend_ip}:2376"
}