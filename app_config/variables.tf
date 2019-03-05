variable "frontend_ip" {
  description = "The IP for the Frontend Container"
}

variable "backend_ip" {
  description = "The IP of the Database Container"
}

variable "domain_name" {
  description = "The domain name to proxy in NGINX"
}

variable "access_key" {
  description = "The Storage Access Key"
}

variable "docker_username" {
  description = "The username to login to docker registry"
}

variable "docker_password" {
  description = "The password to login to docker registry"
}
