output "aws_public_ip" {
  value = "${module.aws.public_ip}"
}

output "azure_public_ip" {
  value = "${module.azure.public_ip}"
}
