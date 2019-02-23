variable "cidr_block" {
  description = "The CIDR block for the VPC."
  default     = "10.12.0.0/16"
}

variable "tags" {
  description = "A mapping of tags to assign to the resource."
  default     = {}
}

variable "public_key_path" {
  description = "The path to the public key to upload to KMS"
  default     = "./meetup_sshkey.pub"
}

variable "userdata_path" {
  description = "Path to the script housing your userdata setup."
  default     = "./scripts/setup_vm.sh"
}
