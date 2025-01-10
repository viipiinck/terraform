module "vpc" {
  source            = "./modules/vpc"
  vpc_range         = var.vpc_range
  availability_zone = var.availability_zone
}