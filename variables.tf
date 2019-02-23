variable "cidr_block" {
  description = "The CIDR block for the VPC."
  default = "10.12.0.0/16"
}

variable "tags" {
  description = "A mapping of tags to assign to the resource."
  default   = { }
}

variable "key_name" {
  description = "The Name of the generated key to add to KMS"
}

variable "public_key_path" {
  description = "The path to the public key to upload to KMS"
}