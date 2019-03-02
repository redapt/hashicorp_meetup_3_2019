provider "docker" {
  alias = "fe"
  host = "tcp://${var.frontend_ip}:2376"
}

provider "docker" {
  alias = "db"
  host = "tcp://${var.database_ip}:2376"
}
