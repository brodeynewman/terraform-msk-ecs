resource "aws_vpc" "main" {
  cidr_block = "10.10.0.0/16"

  tags = {
    Name = "MSK main vpc"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "MSK vpc internet gateway"
  }
}

resource "aws_route_table" "gw" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
}

resource "aws_route_table" "ngw" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.gw.id
  }
}

resource "aws_route_table" "ngw2" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.gw2.id
  }
}

resource "aws_nat_gateway" "gw" {
  allocation_id = aws_eip.nat1.id
  subnet_id     = aws_subnet.public_az1.id
}

resource "aws_nat_gateway" "gw2" {
  allocation_id = aws_eip.nat2.id
  subnet_id     = aws_subnet.public_az2.id
}

resource "aws_route_table_association" "pub_a1" {
  subnet_id      = aws_subnet.public_az1.id
  route_table_id = aws_route_table.gw.id
}

resource "aws_route_table_association" "pub_a2" {
  subnet_id      = aws_subnet.public_az2.id
  route_table_id = aws_route_table.gw.id
}

resource "aws_route_table_association" "priv_a1" {
  subnet_id      = aws_subnet.private_az1.id
  route_table_id = aws_route_table.ngw.id
}

resource "aws_route_table_association" "priv_a2" {
  subnet_id      = aws_subnet.private_az2.id
  route_table_id = aws_route_table.ngw2.id
}

resource "aws_eip" "nat1" {
  vpc = true
}

resource "aws_eip" "nat2" {
  vpc = true
}

resource "aws_subnet" "private_az1" {
  availability_zone       = var.availability_zones[0]
  map_public_ip_on_launch = true
  cidr_block              = "10.10.10.0/24"
  vpc_id                  = aws_vpc.main.id

  tags = {
    Name = "MSK private subnet for ${var.availability_zones[0]}"
  }
}

resource "aws_subnet" "private_az2" {
  availability_zone       = var.availability_zones[1]
  map_public_ip_on_launch = true
  cidr_block              = "10.10.20.0/24"
  vpc_id                  = aws_vpc.main.id

  tags = {
    Name = "MSK private subnet for ${var.availability_zones[1]}"
  }
}

resource "aws_subnet" "public_az1" {
  availability_zone       = var.availability_zones[0]
  map_public_ip_on_launch = true
  cidr_block              = "10.10.30.0/24"
  vpc_id                  = aws_vpc.main.id

  tags = {
    Name = "MSK public subnet for ${var.availability_zones[0]}"
  }
}

resource "aws_subnet" "public_az2" {
  availability_zone       = var.availability_zones[1]
  map_public_ip_on_launch = true
  cidr_block              = "10.10.40.0/24"
  vpc_id                  = aws_vpc.main.id

  tags = {
    Name = "MSK public subnet for ${var.availability_zones[1]}"
  }
}