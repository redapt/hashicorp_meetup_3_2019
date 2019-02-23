variable "name" {
  description = "The name of the Azure Resource Group to deploy to."
}

variable "location" {
  description = "The Azure location you'd like to deploy to"
}

variable "tags" {
  description = "A mapping of tags to assign to the resource."
  default     = {}
}

variable "script_path" {
  description = "The path to the bootstrap script"
}

variable "public_key_path" {
  description = "The path to the SSH public key to be added to authorized_keys"
}
