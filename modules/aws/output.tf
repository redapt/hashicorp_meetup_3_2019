output "public_ip" {
  value = "${aws_instance.docker.public_ip}"
}
