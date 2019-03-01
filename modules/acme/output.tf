output "certificate_url" {
  value = "${acme_certificate.cert.certificate_url}"
}

output "certificate_domain" {
  value = "${acme_certificate.cert.certificate_domain}"
}

output "account_ref" {
  value = "${acme_certificate.cert.account_ref}"
}

output "private_key_pem" {
  value = "${acme_certificate.cert.private_key_pem}"
  sensitive = true
}

output "certificate_pem" {
  value = "${acme_certificate.cert.certificate_pem}"
}

output "issuer_pem" {
  value = "${acme_certificate.cert.issuer_pem}"
}
