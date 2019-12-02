# AZ lookup
data "aws_availability_zones" "available" {
  state = "available"
}

# Minimal VPC config for demo
module "vpc" {
  source         = "terraform-aws-modules/vpc/aws"
  cidr           = "10.211.0.0/16"
  public_subnets = ["10.211.214.0/27", "10.211.213.0/27"]
  azs            = data.aws_availability_zones.available.names
}