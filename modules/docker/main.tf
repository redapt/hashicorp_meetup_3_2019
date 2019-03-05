resource "docker_image" "app" {
  name = "${data.docker_registry_image.redaptu.name}"
  keep_locally = true
  pull_triggers = ["${data.docker_registry_image.redaptu.sha256_digest}"]
}

resource "docker_container" "frontend" {
  provider = "docker.fe"
  depends_on = [
    "docker_container.mssql",
    "null_resource.setup_sql"
  ]
  name = "redapt_university"
  image = "${docker_image.app.latest}"
  
 
 env = [
   "SQLCONNSTR_SchoolContext=${data.template_file.connection_string.rendered}"
 ]

  ports {
    internal = 80
    external = 80
  }

  ports {
    internal = 443
    external = 443
  }
}

resource "null_resource" "add_remote_files" {
  provisioner "file" {
    content =  "${data.terraform_remote_state.state.certificate_pem}"
    destination = "/home/ubuntu/cert.crt"

    connection {
      host           = "${var.frontend_ip}"
      type           = "ssh"
      user           = "ubuntu"
      agent          = true
      agent_identity = "ubuntu"
    }
  }

  provisioner "file" {
    content =  "${data.terraform_remote_state.state.private_key_pem}"
    destination = "/home/ubuntu/cert.key"

    connection {
      host           = "${var.frontend_ip}"
      type           = "ssh"
      user           = "ubuntu"
      agent          = true
      agent_identity = "ubuntu"
    }
  }

  provisioner "file" {
    content =  "${data.template_file.nginx.rendered}"
    destination = "/home/ubuntu/redaptu.conf"

    connection {
      host           = "${var.frontend_ip}"
      type           = "ssh"
      user           = "ubuntu"
      agent          = true
      agent_identity = "ubuntu"
    }
  }
}

resource "random_string" "sql_password" {
  length = 16
  special = false
}

resource "docker_image" "mssql" {
  name = "${data.docker_registry_image.mssql.name}"
  keep_locally = true
  pull_triggers = ["${data.docker_registry_image.mssql.sha256_digest}"]  
}

resource "docker_container" "mssql" {
  provider = "docker.db"
  name = "redaptu-sql"
  image = "${docker_image.mssql.latest}"
  restart = "always"
  start = true
  ports {
    internal = 1433
    external = 1433
    protocol = "tcp"
  }

  env = [
    "ACCEPT_EULA=true",
    "SA_PASSWORD=${random_string.sql_password.result}"
  ]
}

resource "null_resource" "setup_sql" {
  depends_on = ["docker_container.mssql"]

  provisioner "local-exec" {
    command = "sleep 60"
  }
  provisioner "local-exec" {
    command = "sqlcmd -S ${var.database_ip} -U sa -P ${random_string.sql_password.result} -d master -W -i ${path.module}/scripts/SQLConfig.sql"
  }
}