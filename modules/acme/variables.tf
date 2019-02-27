
variable "email_address" {
  description = "The contact email address for the account."
  default = "cloudsupport@redapt.com"
}

variable "domain_name" {
  description = "The certificate's common name, the primary domain that the certificate will be recognized for."
}

variable "subject_alternative_names" {
  type = "list"
  description = "The certificate's subject alternative names, domains that this certificate will also be recognized for."
  default = []
}

