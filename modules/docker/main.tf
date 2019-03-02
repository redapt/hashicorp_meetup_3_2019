
resource "docker_container" "frontend" {
  depends_on = ["docker_container.mssql"]
  name = "${data.docker_registry_image.redaptu.name}"
  pull_triggers = ["${data.docker_registry_image.redaptu.sha256_digest}"]
 
 // Terraform is not an orchestrator, Jenkins however... is!
 env {

 }
}

resource "null_resource" "add_remote_files" {
  provisioner "file" {
    content =  "${data.terraform_remote_state.state.certificate_pem}"
    destination = "/home/ubuntu/cert.pem"

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

resource "docker_container" "nginx" {
  depends_on = ["null_resource.add_remote_files"]
  name = "${data.docker_registry_image.nginx.name}"
  pull_triggers = ["${data.docker_registry_image.nginx.sha256_digest}"]
  privileged = true
  network_mode = "host"

  ports {
    internal = 443
    external = 443
  }

  ports {
    internal = 80
    external = 80
  }

  volumes {
    host_path = "/home/ubuntu/redaptu.conf"
    container_path = "/etc/nginx/sites-available/redaptu.${var.domain_name}.conf"
    read_only = true
  }

  volumes {
    host_path = "/home/ubuntu/redaptu.conf"
    container_path = "/etc/nginx/sites-enabled/redaptu.${var.domain_name}.conf"
    read_only = true
  }

  volumes {
    host_path = "/home/ubuntu/cert.key"
    container_path = "/etc/nginx/cert.key"
  }

  volumes {
    host_path = "/home/ubuntu/cert.pem"
    container_path = "/etc/nginx/cert.pem"
  }
}

resource "random_string" "sql_password" {
  length = 16
  special = false
}


resource "docker_container" "mssql" {
  name = "${data.docker_registry_image.mssql.name}"
  pull_triggers = ["${data.docker_registry_image.mssql.sha256_digest}"]
  restart = "always"
  start = true
  ports {
    internal = 1433
    external = 1433
    protocol = "tcp"
  }

  env {
    ACCEPT_EULA = true
    SA_PASSWORD = "${random_string.sql_password.result}"
  }
}