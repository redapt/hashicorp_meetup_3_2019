output "id" {
  description = "The ID(s) of the records being created"
  value       = "${cloudflare_record.record.*.id}"
}

output "hostname" {
  description = "The FQDN of the record"
  value       = "${cloudflare_record.record.*.hostname}"
}

output "proxiable" {
  description = "Shows whether this record can be proxied, must be true if setting proxied=true"
  value       = "${cloudflare_record.record.*.proxiable}"
}

output "created_on" {
  description = "The RFC3339 timestamp of when the record was created"
  value       = "${cloudflare_record.record.*.created_on}"
}

output "modified_on" {
  description = "The RFC3339 timestamp of when the record was last modified"
  value       = "${cloudflare_record.record.*.modified_on}"
}

output "metadata" {
  description = "A key-value map of string metadata cloudflare associates with the record"
  value       = "${cloudflare_record.record.*.metadata}"
}

output "zone_id" {
  description = "The zone id of the record"
  value       = "${cloudflare_record.record.*.zone_id}"
}
