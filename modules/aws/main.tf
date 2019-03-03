# Import SSH KeyPair
resource "aws_key_pair" "keypair" {
  key_name   = "${var.key_name}"
  public_key = "${file(var.public_key_path)}"
}

# Create VM host for Docker
resource "aws_instance" "docker" {
  ami                         = "${data.aws_ami.ubuntu.id}"
  instance_type               = "t2.small"
  key_name                    = "${var.key_name}"
  associate_public_ip_address = true
  vpc_security_group_ids      = ["${aws_security_group.sg.id}"]
  subnet_id                   = "${aws_subnet.subnet.id}"
  key_name                    = "${aws_key_pair.keypair.key_name}"
  tags                        = "${var.tags}"

  root_block_device {
    volume_size = 32
    volume_type = "gp2"
  }

  provisioner "remote-exec" {
    script = "${var.script_path}"

    connection {
      type           = "ssh"
      user           = "ubuntu"
      agent          = true
      agent_identity = "ubuntu"
    }
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = "${aws_vpc.vpc.id}"

  tags {
    Project  = "Hashicorp Meetup 3/6/2019"
    Location = "us-west-2"
  }
}

resource "aws_route_table_association" "rta" {
  route_table_id = "${aws_vpc.vpc.default_route_table_id}"
  subnet_id      = "${aws_subnet.subnet.id}"
}

resource "aws_route" "egress" {
  route_table_id         = "${aws_vpc.vpc.default_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.gw.id}"
}

resource "aws_vpc" "vpc" {
  cidr_block = "${var.cidr_block}"

  tags {
    Project  = "Hashicorp Meetup 3/6/2019"
    Location = "us-west-2"
  }
}

resource "aws_subnet" "subnet" {
  vpc_id     = "${aws_vpc.vpc.id}"
  cidr_block = "${cidrsubnet(aws_vpc.vpc.cidr_block, 8, 1)}"

  tags {
    Project  = "Hashicorp Meetup 3/6/2019"
    Location = "us-west-2"
  }
}

resource "aws_security_group" "sg" {
  vpc_id = "${aws_vpc.vpc.id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 0
    to_port     = 8
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 2375
    to_port     = 2375
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Project  = "Hashicorp Meetup 3/6/2019"
    Location = "us-west-2"
  }
}