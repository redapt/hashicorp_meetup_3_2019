# Import SSH KeyPair
resource "aws_key_pair" "keypair" {
  key_name   = "${var.key_name}"
  public_key = "${file(var.public_key_path)}"
}

# Create VM host for Docker
resource "aws_instance" "docker" {
  ami           = "${data.aws_ami.ubuntu.id}"
  instance_type = "t2.micro"
  key_name      = "${var.key_name}"
  tags          = "${var.tags}"

  provisioner "remote-exec" {
    script = "${var.script_path}"
    connection {
      type = "ssh"
      user = "ubuntu"
      agent = true
      agent_identity = "ubuntu"
    }
  }
}

# Create Public IP
resource "aws_eip" "public" {
  instance = "${aws_instance.docker.id}"
  vpc      = true
  tags     = "${var.tags}"
}
