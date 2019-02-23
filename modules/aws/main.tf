resource "aws_vpc" "vpc" {
  cidr_block = "10.12.0.0/16"
  tags       = "${var.tags}"
}

resource "aws_subnet" "subnet" {
  vpc_id     = "${aws_vpc.vpc.id}"
  cidr_block = "${cidrsubnet(aws_vpc.vpc.cidr_block, 8, 12)}"
  tags       = "${var.tags}"
}

# Allow Internet connectivity
resource "aws_internet_gateway" "gw" {
  vpc_id = "${data.aws_vpc.selected.id}"

  tags = "${var.tags}"
}

# Add FE subnets to default route table
resource "aws_route_table_association" "rta" {
  count          = "${length(data.aws_availability_zones.all.names)}"
  subnet_id      = "${aws_subnet.subnet.id}"
  route_table_id = "${aws_vpc.vpc.default_route_table_id}"
}

# Add route to internet gateway for outbound
resource "aws_route" "allow_outbound" {
  route_table_id         = "${aws_vpc.vpc.default_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.gw.id}"
}

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
