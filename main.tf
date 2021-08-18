provider "aws" {
  profile = "default"
  region  = "eu-west-1"
}

resource "aws_s3_bucket" "dev_bucket" {
  bucket_prefix = "terraform-dev-"
  acl           = "private"

}

resource "aws_vpc" "dev_VPC" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "dev_VPC"
  }
}

resource "aws_internet_gateway" "dev_IGW" {
  vpc_id = aws_vpc.dev_VPC.id

  tags = {
    Name = "dev_IGW"
  }
}

resource "aws_route_table" "dev_routes_01" {
  vpc_id = aws_vpc.dev_VPC.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.dev_IGW.id
  }
}

resource "aws_subnet" "dev_subnet_01" {
  vpc_id            = aws_vpc.dev_VPC.id
  cidr_block        = cidrsubnet(aws_vpc.dev_VPC.cidr_block, 4, 0)
  availability_zone = "eu-west-1a"
    map_public_ip_on_launch = "true"

  tags = {
    Name = "dev_subnet_01"
  }
}

resource "aws_route_table_association" "dev_rta" {
  subnet_id      = aws_subnet.dev_subnet_01.id
  route_table_id = aws_route_table.dev_routes_01.id
}

resource "aws_security_group" "dev_sg" {
  vpc_id = aws_vpc.dev_VPC.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["37.228.214.55/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_key_pair" "dev_keypair" {
  key_name   = "dev_key"
  # public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDmjvo18YzmFQxi8IkDdqjlazFq7+WXLr6D+AU1AIH/VjNhzwUFZqzEErxPyPGgW5eo4gb7Y69V3I3RDL5L3ulodwOl/FqrgDDH3EtycRuU8q1LJMFMPsiTDszoxgdsc+o6oaCib+trGzKqzLBzGQQH8g4SmTmLYNYVQINt3lDimSSL3siEkHR6en/hIHoFTXWQhkgTmwhrKeq5XFwuJFWbriLHH3ojWGYmVxOfUksYeYknLD5eNY5F4WGXQn7gVsb34lDoDkEycGJJHHPkLq6QkbYXhn0Tv0eWanIcQxxALGhzsLnmkKD1drOVOu7RjpUzRE5a8G35Dw3E+IH8b5yv drcrispy@positronicnet"
  public_key = file("/home/drcrispy/.ssh/id_devkey.pub")
}

resource "aws_instance" "dev_instance" {
  ami                         = "ami-0f89681a05a3a9de7"
  instance_type               = "t2.micro"
  associate_public_ip_address = "true"
  vpc_security_group_ids      = [aws_security_group.dev_sg.id]
  subnet_id                   = aws_subnet.dev_subnet_01.id
  key_name                    = aws_key_pair.dev_keypair.key_name

  tags = {
    Name = "dev_Instance"
  }
}