module "aws" {
  source          = "./modules/aws"
  key_name        = "hashicorp-meetup-key"
  public_key_path = "${var.public_key_path}"
  script_path     = "${var.userdata_path}"
}
