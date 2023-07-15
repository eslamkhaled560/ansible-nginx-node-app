provider "aws" {
    region = "us-east-1"  
}

resource "aws_vpc" "nginx-vpc" {
    cidr_block = "10.0.0.0/16"
    tags = { Name = "nginx-vpc" }
}

resource "aws_internet_gateway" "nginx-igw" {
    vpc_id = aws_vpc.nginx-vpc.id
    tags = { Name = "nginx-igw" }
}

resource "aws_subnet" "nginx-subnet" {
  vpc_id     = aws_vpc.nginx-vpc.id
  cidr_block = "10.0.0.0/24"
  availability_zone = "us-east-1a"
  tags = { Name = "nginx-subnet" }
}

resource "aws_route_table" "nginx-rt" {
  vpc_id = aws_vpc.nginx-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.nginx-igw.id
  }
  tags = { Name = "nginx-rt" }
}

resource "aws_route_table_association" "nginx1-rt-association" {
  subnet_id      = aws_subnet.nginx-subnet.id
  route_table_id = aws_route_table.nginx-rt.id
}

resource "aws_security_group" "nginx-sg" {
  vpc_id      = aws_vpc.nginx-vpc.id

ingress {
    from_port   = 8090
    to_port     = 8090
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow incoming HTTPS connections"
  }
ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow incoming HTTP connections"
  }
ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow incoming SSH connections"
  }
egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
  tags = { Name = "nginx-sg" }
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "nginx" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.nginx-subnet.id
  vpc_security_group_ids      = [aws_security_group.nginx-sg.id]
  associate_public_ip_address = true
  key_name = "win11-key"

  provisioner "local-exec" {
    command = "echo ${self.public_ip} > nginx-pub-ip.txt"
  }
  
  tags = { Name = "tf-nginx" }
  }