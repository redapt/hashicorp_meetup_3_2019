variable "domain_name" {
  description = "The domain name being administered by CloudFlare."
}

variable "num_records" {
  description = "the number of records to create"
}

variable "record_type" {
  description = "The type of DNS record to create"
  default     = "A"
}

variable "record_names" {
  type        = "list"
  description = "The names of the records that you want to apply"
}

variable "record_value" {
  type        = "list"
  description = "The string value of the record."
}

variable "proxied" {
  description = "Whether the record gets Cloudflare's origin protection; defaults to false."
  default     = false
}
