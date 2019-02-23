variable "domain_name" {
  description = "The domain name being administered by CloudFlare."
}

variable "pool_name1" {
  description = "Name of the first pool member"
}

variable "pool_name2" {
  description = "Name of the second pool member"
}


variable "pool_address1" {
  description = "Address of pool 1"
}

variable "pool_address2" {
  description = "Address of pool 2"
}

variable "num_records" {
  description = "the number of records to create"
}

variable "record_type" {
  description = "The type of DNS record to create"
  default = "A"
}

variable "record_names" {
  type = "list"
  description = "The names of the records that you want to apply"
}

variable "record_value" {
  description = "The string value of the record."
}
