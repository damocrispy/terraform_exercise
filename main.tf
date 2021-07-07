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

resource "aws_subnet" "dev_subnet_01" {
  vpc_id            = aws_vpc.dev_VPC.id
  cidr_block        = cidrsubnet(aws_vpc.dev_VPC.cidr_block, 4, 0)
  availability_zone = "eu-west-1a"
#   map_public_ip_on_launch = "true"

  tags = {
    Name = "dev_subnet_01"
  }
}

resource "aws_subnet" "dev_subnet_02" {
  vpc_id            = aws_vpc.dev_VPC.id
  cidr_block        = cidrsubnet(aws_vpc.dev_VPC.cidr_block, 4, 1)
  availability_zone = "eu-west-1b"
#   map_public_ip_on_launch = "true"

  tags = {
    Name = "dev_subnet_02"
  }
}

resource "aws_network_interface" "dev_ENI" {
  subnet_id = aws_subnet.dev_subnet_01.id

  tags = {
    Name = "primary_network_interface"
  }
}

resource "aws_instance" "dev_Instance" {
  ami                         = "ami-0f89681a05a3a9de7"
  instance_type               = "t2.micro"
#   associate_public_ip_address = "true"

  network_interface {
    network_interface_id = aws_network_interface.dev_ENI.id
    device_index         = 0
  }

  tags = {
    Name = "dev_Instance"
  }
}

resource "aws_iam_user" "user" {
  name = "damian"
  path = "/"
}

resource "aws_iam_user_ssh_key" "user" {
  username   = aws_iam_user.user.name
  encoding   = "SSH"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDZoR5ooCP8raRv/hDvCRQmTd4zySTVKRKxiov3CvoafntIUJHQr6pLtrrhQaBhPBeHpjXa6BoRoQYdxN+/utUZGTJohpRfDX46gO65SdBu/DXSMxx7zY+zsBWyAu55vxUeNrhNunq7hfSoQElVSQ5CWJVL5nNcx5jecTU9mOlyK7voIb7nrXvRhABY6uehXs2H+yERYI4WIN3YD9VD/jNWz1ws7XPF6ycxB88sHiH7lYiM0mQZIORJC3dtfT5MVy/ZL42gufFYk92wOCwly7Ezm7+4qrlTLHy1Fv26O3A0/WHF+nE1Ob6jITy7irDnKf1tCSDTKAUJQVFLsUA3hb3H drcrispy@positronicnet"
}

resource "aws_route_table" "routes" {
  vpc_id = aws_vpc.dev_VPC.id

  route {
    cidr_block = aws_subnet.dev_subnet_01.cidr_block
    gateway_id = aws_internet_gateway.dev_IGW.id
  }

  route {
    cidr_block = aws_subnet.dev_subnet_02.cidr_block
    gateway_id = aws_internet_gateway.dev_IGW.id
  }

}
