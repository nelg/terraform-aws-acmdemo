# AWS account that contains the route53 domain
provider "aws" {
  alias = "account_route53" # Specific to your setup
}

# your normal provider
provider "aws" {}
