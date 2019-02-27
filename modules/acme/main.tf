resource "tls_private_key" "private" {
  algorithm = "RSA"
}

resource "acme_registration" "reg" {
  account_key_pem = "${tls_private_key.private.private_key_pem}"
  email_address = "${var.email_address}"
}

resource "acme_certificate" "cert" {
  account_key_pem = "${acme_registration.reg.account_key_pem}"
  common_name = "${var.domain_name}"
  subject_alternative_names = "${var.subject_alternative_names}"
  
  dns_challenge {
    provider = "cloudflare"
  }
}
