output "vpc_id" {
    value = aws_vpc.custom_vpc.id
}
output "az" {
    value = var.availability_zone
  
}