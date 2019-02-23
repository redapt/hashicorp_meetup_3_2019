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
