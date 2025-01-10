resource "aws_vpc" "custom_vpc" {
    cidr_block = var.vpc_range
    enable_dns_hostnames = true
    enable_dns_support = true
    tags = {
      Name ="custom_vpc"
    }
}
