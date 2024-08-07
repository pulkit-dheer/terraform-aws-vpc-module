resource "aws_vpc" "main" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "main"
  }
}

variable "subnets_cidr" {
  description = "Total number of subnets"
  type = map(string)
  default = {
    "us-east-1a" = "10.0.1.0/24", 
    "us-east-1b" = "10.0.2.0/24",
    "us-east-1c" = "10.0.3.0/24" 
    }
  
}

resource "aws_subnet" "sub" {
  vpc_id     = aws_vpc.main.id
  for_each = var.subnets_cidr
  cidr_block = each.value
  availability_zone = each.key

  tags = {
    Name = each.key
  }
}


resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "igw"
  }
}


resource "aws_route_table" "routetable" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "routetable"
  }
}






resource "aws_security_group" "allow_tls" {
   name = "allow_tls"
   description = "Allow TLS inbound traffic"
   vpc_id = aws_vpc.main.id

  ingress {
    description = "TLS from VPC"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]

  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]

  }

}