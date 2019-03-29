data "docker_registry_image" "redaptu" {
  name = "iancornett/redaptuniversity:latest"
}

data "docker_registry_image" "mssql" {
  name = "mcr.microsoft.com/mssql/server:2017-latest"
}

data "docker_registry_image" "nginx" {
  name = "nginx:stable"
}

data "terraform_remote_state" "state" {
  backend = "azurerm"

  config {
    access_key           = "${var.access_key}"
    storage_account_name = "redapthashicorpmeetup"
    container_name       = "terraform-storage"
    key                  = "hashicorp-platform.tfstate"
  }
}

data "template_file" "nginx" {
  template = "${file("${path.module}/templates/nginx.tpl")}"

  vars = {
    DOMAIN_NAME = "${var.domain_name}"
  }
}

data "template_file" "connection_string" {
  template = "${file("${path.module}/templates/connstr.tpl")}"

  vars = {
    DB_IP = "${var.database_ip}"
  }
}
