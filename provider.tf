# AWS account that contains the route53 domain
provider "aws" {
  alias = "account_route53" # Specific to your setup
  version = ">= 3.4.0"
}

# your normal provider
provider "aws" {
  version = ">= 3.4.0"
}

terraform {
  required_version = ">= 0.13.1"
}
