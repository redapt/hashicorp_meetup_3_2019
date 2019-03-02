output "aws_public_ip" {
  value = "${module.aws.public_ip}"
}

output "azure_public_ip" {
  value = "${module.azure.public_ip}"
}

output "certificate_url" {
  value = "${module.letsencrypt.certificate_url}"
}

output "certificate_domain" {
  value = "${module.letsencrypt.certificate_domain}"
}

output "private_key_pem" {
  value     = "${module.letsencrypt.private_key_pem}"
  sensitive = true
}

output "certificate_pem" {
  value = "${module.letsencrypt.certificate_pem}"
}

output "issuer_pem" {
  value = "${module.letsencrypt.issuer_pem}"
}

output "id" {
  description = "The ID(s) of the records being created"
  value       = "${module.cloudflare.id}"
}

output "hostname" {
  description = "The FQDN of the record"
  value       = "${module.cloudflare.hostname}"
}

output "proxiable" {
  description = "Shows whether this record can be proxied, must be true if setting proxied=true"
  value       = "${module.cloudflare.proxiable}"
}

output "created_on" {
  description = "The RFC3339 timestamp of when the record was created"
  value       = "${module.cloudflare.created_on}"
}

output "modified_on" {
  description = "The RFC3339 timestamp of when the record was last modified"
  value       = "${module.cloudflare.modified_on}"
}

output "metadata" {
  description = "A key-value map of string metadata cloudflare associates with the record"
  value       = "${module.cloudflare.metadata}"
}

output "zone_id" {
  description = "The zone id of the record"
  value       = "${module.cloudflare.zone_id}"
}
