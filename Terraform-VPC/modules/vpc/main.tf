resource "aws_vpc" "custom_vpc" {
    cidr_block = var.vpc_range
    enable_dns_hostnames = true
    enable_dns_support = true
    tags = {
      Name ="custom_vpc"
    }
}
resource "aws_subnet" "public_subnet" {
  vpc_id = aws_vpc.custom_vpc.id
  count = length(var.availability_zone)
  cidr_block = cidrsubnet(aws_vpc.custom_vpc.cidr_block,8,count.index+1)
  availability_zone = element(var.availability_zone,count.index)
  tags = {
    Name ="Pub_Sub ${count.index+1}"
  }
}
resource "aws_subnet" "private_subnet" {
  vpc_id = aws_vpc.custom_vpc.id
  count = length(var.availability_zone)
  cidr_block = cidrsubnet(aws_vpc.custom_vpc.cidr_block,8,count.index+3)
  availability_zone = element(var.availability_zone,count.index)
  tags = {
    Name ="Pri_Sub ${count.index+1}"
  }
}
resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.custom_vpc.id
  tags = {
    Name = "my_igw"
  }
}
resource "aws_route_table" "public_subnet_rt" {
  
  vpc_id = aws_vpc.custom_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_igw.id
  }
  tags = {
    Name ="Pub_Sub_Rt"
  }
}
resource "aws_route_table_association" "public_subnet_rta" {
  route_table_id = aws_route_table.public_subnet_rt.id
  count = length(var.availability_zone)
  subnet_id = element(aws_subnet.public_subnet[*].id, count.index)
}
resource "aws_eip" "eip" {
  domain = "vpc"
  depends_on = [ aws_internet_gateway.my_igw ]
  
}
resource "aws_nat_gateway" "my_nat" {
  depends_on = [ aws_internet_gateway.my_igw ]
  subnet_id = element(aws_subnet.private_subnet[*].id, 0)
  allocation_id = aws_eip.eip.id
tags = {
  Name ="My_Nat_Gateway"
}
}
resource "aws_route_table" "private_subnet_rt" {
  vpc_id = aws_vpc.custom_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.my_nat.id
  }
  depends_on = [aws_nat_gateway.my_nat]
  tags = {
    Name = " Pri_Sub_Rt"
  }
}
resource "aws_route_table_association" "private_subnet_rta" {
  route_table_id = aws_route_table.private_subnet_rt.id
  count          = length(var.availability_zone)
  subnet_id      = element(aws_subnet.private_subnet[*].id, count.index)
}