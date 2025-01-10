variable "vpc_range" {
  type        = string
  description = "CIDR Range for VPC"
}
variable "availability_zone" {
  type        = list(string)
  description = "Available Zone"
}