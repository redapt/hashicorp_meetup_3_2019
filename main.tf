module "aws" {
  source          = "./modules/aws"
  key_name        = "hashicorp-meetup-key"
  public_key_path = "${var.public_key_path}"
  script_path     = "${var.userdata_path}"
  tags            = "${var.tags}"
}

module "azure" {
  source          = "./modules/azure"
  location        = "westus2"
  tags            = "${var.tags}"
  script_path     = "${var.userdata_path}"
  public_key_path = "${var.public_key_path}"
  name            = "hashicorp-meetup"
}

module "cloudflare" {
  source       = "./modules/cloudflare"
  domain_name  = "${var.domain_name}"
  record_names = "${var.record_names}"

  record_value = [
    "${module.aws.public_ip}",
    "${module.azure.public_ip}",
  ]

  proxied = "${var.proxied}"
}

module "letsencrypt" {
  source        = "./modules/acme"
  email_address = "${var.email_address}"
  domain_name   = "${var.domain_name}"

  subject_alternative_names = [
    "redaptu.redaptdemo.com",
    "redaptdb.redaptdemo.com",
  ]
}

module "docker" {
  source = "../modules/docker"
  frontend_ip = "${module.aws.public_ip}"
  database_ip = "${module.azure.public_ip}"
  domain_name = "${var.domain_name}"
}