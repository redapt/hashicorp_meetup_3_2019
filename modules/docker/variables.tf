variable "frontend_ip" {
  description = "The IP for the Frontend Container"
}

variable "database_ip" {
  description = "The IP of the Database Container"
}

variable "domain_name" {
  description = "The domain name to proxy in NGINX"
}
