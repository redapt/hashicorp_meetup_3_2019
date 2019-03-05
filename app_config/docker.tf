module "docker" {
  source      = "../modules/docker"
  frontend_ip = "${var.frontend_ip}"
  database_ip = "${var.backend_ip}"
  domain_name = "${var.domain_name}"
  access_key  = "${var.access_key}"
}
