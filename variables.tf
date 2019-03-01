variable "cidr_block" {
  description = "The CIDR block for the VPC."
  default     = "10.12.0.0/16"
}

variable "tags" {
  description = "A mapping of tags to assign to the resource."

  default = {
    Terraform = true
    Project   = "Hashicorp Meetup 3/6/2019"
  }
}

variable "public_key_path" {
  description = "The path to the public key to upload to KMS"
  default     = "./meetup_sshkey.pub"
}

variable "userdata_path" {
  description = "Path to the script housing your userdata setup."
  default     = "./scripts/setup_vm.sh"
}

variable "domain_name" {
  description = "The domain name being administered by CloudFlare."
  default     = "redaptdemo.com"
}

variable "record_type" {
  description = "The type of DNS record to create"
  default     = "A"
}

variable "record_names" {
  type        = "list"
  description = "The names of the records that you want to apply"

  default = [
    "redaptu",
    "redaptdb",
  ]
}

variable "proxied" {
  description = "Whether the record gets Cloudflare's origin protection; defaults to false."
  default     = false
}

variable "email_address" {
  description = "The contact email address for the account."
  default     = "cloudsupport@redapt.com"
}

variable "subject_alternative_names" {
  type        = "list"
  description = "The certificate's subject alternative names, domains that this certificate will also be recognized for."
  default     = []
}
