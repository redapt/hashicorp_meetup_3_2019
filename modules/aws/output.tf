output "public_ip" {
  value = "${aws_eip.public.public_ip}"
}
